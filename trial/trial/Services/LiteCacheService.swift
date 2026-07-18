//
//  LiteCacheService.swift
//  Eternal Lite — Local Caching Layer
//
//  PURPOSE: Offline-first caching for menu data, addresses, and payment methods.
//  Repeat app opens don't re-fetch static data — they load from cache instantly.
//
//  APPLE API: Foundation (FileManager + JSONEncoder/Decoder)
//  We use a simple file-based cache with ETag/timestamp validation instead of
//  SwiftData to keep dependencies minimal and hackathon-friendly.
//
//  HACKATHON ANGLE: This eliminates repeat fetches for data that rarely changes.
//  Combined with batched fetching, a returning user on a bad network sees their
//  menu INSTANTLY from cache with ZERO API calls.
//

import Foundation
import Combine

/// Metadata stored alongside each cached item to support ETag/freshness checks.
public struct CacheMetadata: Codable {
    public let key: String
    public let lastUpdated: Date
    public let etag: String?
    public let sizeBytes: Int
    
    public init(key: String, lastUpdated: Date = Date(), etag: String? = nil, sizeBytes: Int = 0) {
        self.key = key
        self.lastUpdated = lastUpdated
        self.etag = etag
        self.sizeBytes = sizeBytes
    }
}

/// Result type for cache lookups — tells the caller whether data came from cache or network.
public enum CacheResult<T> {
    case hit(T, age: TimeInterval)   // Data found in cache, with its age in seconds
    case miss                         // No cached data available
    case stale(T, age: TimeInterval) // Data exists but is older than maxAge
}

@MainActor
public final class LiteCacheService: ObservableObject {
    public static let shared = LiteCacheService()
    
    // MARK: - Published State (for Debug Overlay)
    
    /// The result of the last cache operation — shown in DebugOverlay
    @Published public var lastCacheResult: String = "—"
    
    /// Total number of cache hits this session
    @Published public var cacheHitCount: Int = 0
    
    /// Total number of cache misses this session
    @Published public var cacheMissCount: Int = 0
    
    // MARK: - Private
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// Cache directory: <AppSupport>/EternalLiteCache/
    private let cacheDirectory: URL
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        cacheDirectory = appSupport.appendingPathComponent("EternalLiteCache", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Core Cache Operations
    
    /// Save any Codable data to the cache with a string key.
    /// Stores both the data and its metadata (timestamp, size) side by side.
    public func cache<T: Codable>(key: String, data: T, etag: String? = nil) {
        do {
            let encoded = try encoder.encode(data)
            let dataURL = cacheDirectory.appendingPathComponent("\(key).json")
            try encoded.write(to: dataURL)
            
            // Store metadata alongside the data
            let metadata = CacheMetadata(key: key, etag: etag, sizeBytes: encoded.count)
            let metaEncoded = try encoder.encode(metadata)
            let metaURL = cacheDirectory.appendingPathComponent("\(key).meta.json")
            try metaEncoded.write(to: metaURL)
            
            #if DEBUG
            print("💾 LiteCache: Saved \(key) (\(encoded.count) bytes)")
            #endif
        } catch {
            #if DEBUG
            print("❌ LiteCache: Failed to cache \(key): \(error.localizedDescription)")
            #endif
        }
    }
    
    /// Load cached data for a given key. Returns nil if not found.
    public func load<T: Codable>(key: String, type: T.Type) -> T? {
        let dataURL = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: dataURL) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
    
    /// Load cached data with freshness check.
    /// - Parameter maxAge: Maximum age in seconds before data is considered stale.
    /// - Returns: `.hit` if fresh, `.stale` if expired, `.miss` if not cached.
    public func loadWithFreshness<T: Codable>(key: String, type: T.Type, maxAge: TimeInterval) -> CacheResult<T> {
        let dataURL = cacheDirectory.appendingPathComponent("\(key).json")
        let metaURL = cacheDirectory.appendingPathComponent("\(key).meta.json")
        
        guard let data = try? Data(contentsOf: dataURL),
              let decoded = try? decoder.decode(T.self, from: data) else {
            cacheMissCount += 1
            lastCacheResult = "MISS ✗"
            return .miss
        }
        
        // Check metadata for freshness
        let age: TimeInterval
        if let metaData = try? Data(contentsOf: metaURL),
           let metadata = try? decoder.decode(CacheMetadata.self, from: metaData) {
            age = Date().timeIntervalSince(metadata.lastUpdated)
        } else {
            age = .infinity // No metadata = treat as stale
        }
        
        if age <= maxAge {
            cacheHitCount += 1
            lastCacheResult = "HIT ✓ (\(Int(age))s old)"
            #if DEBUG
            print("✅ LiteCache: HIT for \(key) — \(Int(age))s old (max: \(Int(maxAge))s)")
            #endif
            return .hit(decoded, age: age)
        } else {
            // Data exists but is stale
            lastCacheResult = "STALE (\(Int(age))s old)"
            #if DEBUG
            print("⚠️ LiteCache: STALE for \(key) — \(Int(age))s old (max: \(Int(maxAge))s)")
            #endif
            return .stale(decoded, age: age)
        }
    }
    
    /// Check if a cache entry exists and is valid (under maxAge).
    public func isCacheValid(key: String, maxAge: TimeInterval) -> Bool {
        let metaURL = cacheDirectory.appendingPathComponent("\(key).meta.json")
        guard let metaData = try? Data(contentsOf: metaURL),
              let metadata = try? decoder.decode(CacheMetadata.self, from: metaData) else {
            return false
        }
        return Date().timeIntervalSince(metadata.lastUpdated) <= maxAge
    }
    
    /// Clear all cached data.
    public func clearAll() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        cacheHitCount = 0
        cacheMissCount = 0
        lastCacheResult = "CLEARED"
        #if DEBUG
        print("🗑 LiteCache: All cache cleared")
        #endif
    }
    
    /// Reset session counters (for demo purposes)
    public func resetCounters() {
        cacheHitCount = 0
        cacheMissCount = 0
        lastCacheResult = "—"
    }
}

//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                do {
                    let items = try FeedItemsMapper.map(data, from: response)
                    return completion(.success(items.toModel()))
                } catch {
                    return completion(.failure(error))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
}

extension Array where Element == RemoteFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }
    }
}

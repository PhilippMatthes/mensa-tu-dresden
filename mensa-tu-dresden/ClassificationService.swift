// From https://github.com/cocoa-ai/SentimentCoreMLDemo/blob/master/SentimentPolarity/ClassificationService.swift

import CoreML


@available(iOS 11.0, *)
final class ClassificationService {
    private enum Error: Swift.Error {
        case featuresMissing
    }
    
    private let model = SentimentPolarity()
    private let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    private lazy var tagger: NSLinguisticTagger = .init(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: Int(self.options.rawValue)
    )
    
    // MARK: - Prediction
    func predictStars(from text: String, completion: @escaping (Int) -> ()) {
        features(from: text) {
            inputFeatures in
            guard
                inputFeatures.count > 1,
                let output = try? self.model.prediction(input: inputFeatures),
                let positive = output.classProbability["Pos"],
                let negative = output.classProbability["Neg"]
            else {return}
            completion(negative > positive ? 2 : 4)
        }
    }
}

// MARK: - Features
@available(iOS 11.0, *)
private extension ClassificationService {
    func features(from text: String, completion: @escaping ([String: Double]) -> ()) {
        var wordCounts = [String: Double]()
        
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Tokenize and count the sentence
        tagger.enumerateTags(in: range, scheme: .nameType, options: options) { _, tokenRange, _, _ in
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            // Skip small words
            guard token.count >= 3 else {
                return
            }
            
            if let value = wordCounts[token] {
                wordCounts[token] = value + 1.0
            } else {
                wordCounts[token] = 1.0
            }
            completion(wordCounts)
        }
    }
}

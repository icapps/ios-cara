import Foundation
import Hippolyte

public class StubbedRequest {

    init() {
    }

    func request(url: String, statuscode: Int = 200, method: HTTPMethod = .GET, json: [String: Any]? = nil, error: NSError? = nil) {
        guard let url = URL(string: url) else { return }
        var request = StubRequest(method: method, url: url)

        var response: StubResponse
        if let error {
            response = StubResponse(error: error)
        } else {
            response = StubResponse(statusCode: statuscode)
        }

        // Convert your JSON object to Data
        if let json {
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
            response.body = jsonData
            response.headers = ["Content-Type": "application/json"]
        }
        request.response = response

        Hippolyte.shared.add(stubbedRequest: request)
        Hippolyte.shared.start()
    }

    func stopStubbedRequest() {
        Hippolyte.shared.stop()
    }
}

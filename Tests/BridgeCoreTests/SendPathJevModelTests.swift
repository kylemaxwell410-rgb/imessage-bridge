import Foundation
import Testing
@testable import BridgeCore

/// Jev rule 9: pin the model version and log the response's `model` field.
@Suite struct SendPathJevModelTests {
    private let config = JevConfig(provider: .typesafe, apiKey: "x", model: "jev-1.14.0", requireNoDataCollection: true)

    private var body: [String: Any] {
        [
            "model": "jev-1.14.0",
            "answers": [JevPrompt.flagQuestions[0]: ["noul": 0.1]],
            "usage": ["cost": 0.0001],
        ]
    }

    @Test func parsedResultCarriesTheServedModel() throws {
        let data = try JSONSerialization.data(withJSONObject: body)
        #expect(try JevClient.parse(status: 200, data: data, config: config).model == "jev-1.14.0")
    }

    @Test func wrappedTypeSafePayloadStillYieldsTheModel() throws {
        let data = try JSONSerialization.data(withJSONObject: ["code": 0, "message": "ok", "data": body])
        #expect(try JevClient.parse(status: 200, data: data, config: config).model == "jev-1.14.0")
    }

    @Test func missingModelFallsBackToTheRequestedOne() throws {
        var b = body
        b["model"] = nil
        let data = try JSONSerialization.data(withJSONObject: b)
        #expect(try JevClient.parse(status: 200, data: data, config: config).model == "jev-1.14.0")
    }

    @Test func screeningSummaryReportsTheModelThatAnswered() {
        var seen: ScreenSummary?
        let s = LayeredScreener(
            config: ScreeningConfig(threshold: 0.5, scanContacts: false, local: nil, jev: config),
            cache: VerdictCache(),
            classifyRemote: { _, _, _ in JevResult(score: 0.1, reason: "remote", cost: 0.001, model: "jev-1.14.0") },
            onSummary: { seen = $0 })
        _ = s.screen([ScreenItem(rowID: 1, text: "dinner at 7?", sender: "+15550100", senderName: nil)])
        #expect(seen?.jevModel == "jev-1.14.0")
    }
}

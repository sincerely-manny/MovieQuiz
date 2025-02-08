//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Кирилл Серебрянный on 07.02.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUpWithError() throws {
    try super.setUpWithError()

    app = XCUIApplication()
    app.launch()

    continueAfterFailure = false
  }
  override func tearDownWithError() throws {
    try super.tearDownWithError()

    app.terminate()
    app = nil
  }

  private func testButton(id: String) {
    sleep(3)
    let firstPoster = app.images["Poster"]
    let firstPosterData = firstPoster.screenshot().pngRepresentation

    app.buttons[id].tap()
    sleep(3)
    let secondPoster = app.images["Poster"]
    let secondPosterData = secondPoster.screenshot().pngRepresentation

    XCTAssertFalse(firstPosterData == secondPosterData)
  }

  func testYesButton() {
    testButton(id: "Yes")
  }
  func testNoButton() {
    testButton(id: "No")
  }
  func testIndexLabel() {
    sleep(3)
    app.buttons["Yes"].tap()
    sleep(3)
    let indexLabel = app.staticTexts["Index"]
    let text = indexLabel.label
    XCTAssertEqual(indexLabel.label, "2/10")
  }

  func testGameFinish() {
    sleep(2)
    for _ in 1...10 {
      app.buttons["No"].tap()
      sleep(2)
    }

    let alert = app.alerts["Этот раунд окончен!"]

    XCTAssertTrue(alert.exists)
    XCTAssertTrue(alert.label == "Этот раунд окончен!")
    XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
  }

  func testAlertDismiss() {
    sleep(2)
    for _ in 1...10 {
      app.buttons["No"].tap()
      sleep(2)
    }

    let alert = app.alerts["Этот раунд окончен!"]
    alert.buttons.firstMatch.tap()

    sleep(2)

    let indexLabel = app.staticTexts["Index"]

    XCTAssertFalse(alert.exists)
    XCTAssertTrue(indexLabel.label == "1/10")
  }
}

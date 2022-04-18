//
//  WeeklyAnalysisSpikeViewController.swift
//  ChartsDemo-iOS-Swift
//
//  Created by Eugene Jegal on 4/13/22.
//  Copyright © 2022 dcg. All rights reserved.
//

import Foundation
import UIKit
import Charts

private let ITEM_COUNT = 7

class WeeklyAnalysisSpikeViewController: UIViewController {
    var chartView = CombinedChartView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        self.title = "Weekly Analysis Test Chart"

        chartView.chartDescription.enabled = false
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = false
        chartView.isUserInteractionEnabled = false
        chartView.drawGridBackgroundEnabled = true

        chartView.drawOrder = [DrawOrder.line.rawValue, DrawOrder.bar.rawValue]

        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     chartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
                                     chartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0)])

        chartView.legend.enabled = false
        chartView.gridBackgroundColor = NSUIColor(red: 66.0/255.0,
                                                  green: 135.0/255.0,
                                                  blue: 245.0/255.0,
                                                  alpha: 0.5)

        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawAxisLineEnabled = false

        let rightAxis = chartView.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
        //rightAxis.valueFormatter = WeightLossZoneAxisFormatter()
        rightAxis.granularity = 10.0

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = -1
        xAxis.granularity = 1
        xAxis.valueFormatter = self
        xAxis.drawGridLinesEnabled = false

        self.setChartData()
    }

    func setChartData() {
        let data = CombinedChartData()
        data.lineData = generateLineData()
        data.barData = generateBarData()

        chartView.xAxis.axisMaximum = Double(ITEM_COUNT)

        chartView.data = data
    }

    func generateLineData() -> LineChartData {
        let bounds = [[60.0, 80.0],
                      [60.0, 80.0],
                      [50.0, 70.0],
                      [60.0, 80.0],
                      [70.0, 90.0],
                      [50.0, 70.0],
                      [60.0, 80.0],
                      [55.0, 75.0],
                      [55.0, 75.0]]
        let lowerBounds = (-1...ITEM_COUNT).map { i -> ChartDataEntry in
            return ChartDataEntry(x: Double(i), y: bounds[i+1][0])
        }

        let upperBounds = (-1...ITEM_COUNT).map { i -> ChartDataEntry in
            return ChartDataEntry(x: Double(i), y: bounds[i+1][1])
        }

        let lowerSet = LineChartDataSet(entries: lowerBounds)
        lowerSet.axisDependency = .left
        lowerSet.drawCirclesEnabled = false
        lowerSet.drawValuesEnabled = false
        lowerSet.mode = .horizontalBezier
        lowerSet.lineWidth = 0.0
        lowerSet.drawFilledEnabled = true
        lowerSet.fillColor = .white
        lowerSet.fillAlpha = 1.0
        lowerSet.fillFormatter = DefaultFillFormatter { _, _ in
            return CGFloat(self.chartView.leftAxis.axisMinimum)
        }

        let upperSet = LineChartDataSet(entries: upperBounds)
        upperSet.axisDependency = .left
        upperSet.drawFilledEnabled = true
        upperSet.drawCirclesEnabled = false
        upperSet.drawValuesEnabled = false
        upperSet.lineWidth = 0.0
        upperSet.mode = .horizontalBezier
        upperSet.fillColor = .white
        upperSet.fillAlpha = 1.0
        upperSet.fillFormatter = DefaultFillFormatter(block: { dataSet, dataProvider in
            return CGFloat(self.chartView.leftAxis.axisMaximum)
        })
        upperSet.label = "WLZ"

        let chartData = LineChartData(dataSets: [upperSet, lowerSet])

        return chartData
    }

    func generateBarData() -> BarChartData {
        let dailyCaloricBreakdown = [[30, 30, 30],
                                     [20, 30, 30],
                                     [20, 45, 10],
                                     [25, 40, 20],
                                     [20, 30, 30],
                                     [10, 30, 50],
                                     [40, 20, 10]]

        let caloricBreakdownChartEntries = zip(dailyCaloricBreakdown.indices, dailyCaloricBreakdown).map { (index, calories) in
            return BarChartDataEntry(x: Double(index),
                                     yValues: calories.map({ return Double($0) }))
        }

        let caloricBreakdownDataSet = BarChartDataSet(entries: caloricBreakdownChartEntries)
        caloricBreakdownDataSet.colors = [.green, .yellow, .red]
        caloricBreakdownDataSet.axisDependency = .left
        caloricBreakdownDataSet.drawValuesEnabled = false
        caloricBreakdownDataSet.barBorderWidth = 2.0
        caloricBreakdownDataSet.barBorderColor = .white

        let chartData = BarChartData(dataSet: caloricBreakdownDataSet)
        chartData.barWidth = 0.48

        return chartData
    }
}

extension WeeklyAnalysisSpikeViewController: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard 0.0..<7.0 ~= value else { return "" }
        let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
        return daysOfWeek[Int(value) % daysOfWeek.count]
    }
}

class WeightLossZoneAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard value >= 50.0 else { return "" }
        return "WLZ"
    }
}

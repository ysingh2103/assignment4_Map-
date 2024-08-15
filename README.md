Stock Monitor Application

This project is a Stock Tracker application that allows users to search for stocks, add them to an active or watch list, and manage them based on their performance. The application fetches real-time stock data using the MS Finance API and stores stock information locally using Core Data.

Features

	•	Search Stocks: Search for stocks using the MS Finance API.
	•	Add to Lists: Add stocks to either an active list or a watchlist.
	•	Manage Stocks: Rank stocks as “Cold,” “Hot,” or “Very Hot,” and move them between lists.
	•	Real-Time Updates: Fetch real-time prices for stocks and update them within the app.
	•	Core Data Integration: Store stock data locally using Core Data.

Requirements

	•	Xcode 12.0 or later
	•	iOS 14.0 or later
	•	Swift 5.0 or later

 Core Data Setup

1. Add Core Data to Your Project

If Core Data is not already included in your project, you can add it manually:

	1.	Create a Data Model:
	•	In Xcode, go to File > New > File... and select Data Model.
	•	Name the data model StockModel (or any name you prefer).
	2.	Define the Entities:
	•	Open the .xcdatamodeld file created in the previous step.
	•	Click on the + button to add a new entity.
	•	Name the entity StockEntity.
	3.	Add Attributes to StockEntity:
	•	symbol: String
	•	name: String
	•	price: Double
	•	isActive: Boolean
	•	isInWatchlist: Boolean
	•	rank: String

2. Generate the NSManagedObject Subclass

	1.	Create NSManagedObject Subclass:
	•	Select the StockEntity in the .xcdatamodeld file.
	•	Go to Editor > Create NSManagedObject Subclass....
	•	Choose your project folder as the destination and click Create.

This will generate two files, StockEntity+CoreDataClass.swift and StockEntity+CoreDataProperties.swift, which will be used to interact with Core Data in your code.

Usage

	1.	Run the Application:
	•	Build and run the project using Xcode.
	2.	Search for Stocks:
	•	Use the search bar to find stocks by their ticker symbol.
	3.	Add Stocks to Lists:
	•	Add the selected stocks to either the active list or the watchlist.
	4.	Manage Stocks:
	•	Rank stocks or move them between the active list and the watchlist.
	5.	View Stock Details:
	•	Tap on a stock to view more detailed information.


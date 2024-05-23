Class {
	#name : 'GolapCSVNodeImporterPresenter',
	#superclass : 'GolapCSVImportPresenter',
	#instVars : [
		'idDropList',
		'nameDropList'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'layout' }
GolapCSVNodeImporterPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: #pathField expand: true;
				   add: #changePathButton expand: false;
				   yourself)
		  expand: false;
		  add: #columnsTable expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: '商品ID' asPresenter width: 80;
				   add: #idDropList expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: '商品名' asPresenter width: 80;
				   add: #nameDropList expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'operations' }
GolapCSVNodeImporterPresenter >> createAggregators [

	| idColumn nameColumn |
	idColumn := self idColumn.
	nameColumn := self nameColumn.
	^ Array streamContents: [ :stream |
		  aggregators keysAndValuesDo: [ :column :string |
			  (column = idColumn or: [ column = nameColumn ]) ifFalse: [
				  column = #sum
					  ifTrue: [
					  stream nextPut: (GolapSumDataAggregator column: column) ]
					  ifFalse: [
						  stream nextPut: (GolapWeightedAverageDataAggregator
								   column: column
								   weightColumn: string) ] ] ] ]
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> dataframeChanged [

	super dataframeChanged.
	self
		updateIdDropList;
		updateNameDropList
]

{ #category : 'accessing' }
GolapCSVNodeImporterPresenter >> idColumn [

	^ idDropList selectedItem
]

{ #category : 'initialization' }
GolapCSVNodeImporterPresenter >> initializePresenters [

	super initializePresenters.
	idDropList := self newDropList whenSelectionChangedDo: [
		              self idColumnChanged ].
	nameDropList := self newDropList whenSelectionChangedDo: [
		                self nameColumnChanged ]
]

{ #category : 'operations' }
GolapCSVNodeImporterPresenter >> loadInto: aGolapModel [

	dataframe ifNil: [ ^ self ].
	aGolapModel
		readNodeDataframe: dataframe
		idColumn: self idColumn
		nameColumn: self nameColumn;
		nodeAggregators: self createAggregators
]

{ #category : 'accessing' }
GolapCSVNodeImporterPresenter >> nameColumn [

	^ nameDropList selectedItem
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> updateIdDropList [

	idDropList items: self availableColumns
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> updateNameDropList [

	nameDropList items: self availableColumns
]

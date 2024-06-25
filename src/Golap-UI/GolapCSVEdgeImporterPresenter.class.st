Class {
	#name : 'GolapCSVEdgeImporterPresenter',
	#superclass : 'GolapCSVImportPresenter',
	#instVars : [
		'idDropList1',
		'idDropList2'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'layout' }
GolapCSVEdgeImporterPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #columnsTable expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: '商品ID1' asPresenter width: 80;
				   add: #idDropList1 expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: '商品ID2' asPresenter width: 80;
				   add: #idDropList2 expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: '評価値' asPresenter width: 80;
				   add: #evaluatorDropList expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'accessing' }
GolapCSVEdgeImporterPresenter >> availableEvaluators [

	^ Array streamContents: [ :stream |
		  dataframe ifNotNil: [
			  dataframe rows ifNotEmpty: [ :rows |
				  ((rows first keys copyWithoutAll: {
						    self idColumn1.
						    self idColumn2 }) select: [ :column |
					   (rows first at: column) isNumber ]) do: [ :column |
					  stream nextPut: (GolapEdgeColumnEvaluator column: column) ] ] ] ]
]

{ #category : 'operations' }
GolapCSVEdgeImporterPresenter >> createAggregators [

	| idColumn1 idColumn2 |
	idColumn1 := self idColumn1.
	idColumn2 := self idColumn2.
	^ Array streamContents: [ :stream |
		  aggregators keysAndValuesDo: [ :column :string |
			  (column = idColumn1 or: [ column = idColumn2 ]) ifFalse: [
				  column = #sum
					  ifTrue: [
					  stream nextPut: (GolapSumDataAggregator column: column) ]
					  ifFalse: [
						  stream nextPut: (GolapWeightedAverageDataAggregator
								   column: column
								   weightColumn: string) ] ] ] ]
]

{ #category : 'updating' }
GolapCSVEdgeImporterPresenter >> dataframeChanged [

	super dataframeChanged.
	self
		updateIdDropList1;
		updateIdDropList2
]

{ #category : 'accessing' }
GolapCSVEdgeImporterPresenter >> idColumn1 [

	^ idDropList1 selectedItem
]

{ #category : 'updating' }
GolapCSVEdgeImporterPresenter >> idColumn1Changed [

	self updateEvaluatorDropList
]

{ #category : 'accessing' }
GolapCSVEdgeImporterPresenter >> idColumn2 [

	^ idDropList2 selectedItem
]

{ #category : 'updating' }
GolapCSVEdgeImporterPresenter >> idColumn2Changed [

	self updateEvaluatorDropList
]

{ #category : 'initialization' }
GolapCSVEdgeImporterPresenter >> initializePresenters [

	super initializePresenters.
	idDropList1 := self newDropList whenSelectionChangedDo: [
		               self idColumn1Changed ].
	idDropList2 := self newDropList whenSelectionChangedDo: [
		               self idColumn2Changed ]
]

{ #category : 'operations' }
GolapCSVEdgeImporterPresenter >> loadInto: aGolapModel [

	dataframe ifNil: [ ^ self ].
	aGolapModel
		readEdgeDataframe: dataframe
		idColumn: self idColumn1
		and: self idColumn2;
		edgeAggregators: self createAggregators;
		edgeEvaluator: self evaluator
]

{ #category : 'updating' }
GolapCSVEdgeImporterPresenter >> updateIdDropList1 [

	idDropList1
		items: self availableColumns;
		selectIndex: 1
]

{ #category : 'updating' }
GolapCSVEdgeImporterPresenter >> updateIdDropList2 [

	idDropList2
		items: self availableColumns;
		selectIndex: 2
]

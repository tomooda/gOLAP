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
				   add: 'アイテムID1' asPresenter width: 80;
				   add: #idDropList1 expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: 'アイテムID2' asPresenter width: 80;
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
			  (dataframe notNil and: [ dataframe notEmpty ]) ifTrue: [
					  | row |
					  row := dataframe rowAt: 1.
					  ((row keys copyWithoutAll: {
							    self idColumn1.
							    self idColumn2 }) select: [ :column |
						   (row at: column) isNumber ]) do: [ :column |
						  stream nextPut: (GolapEdgeColumnEvaluator column: column) ] ] ]
]

{ #category : 'operations' }
GolapCSVEdgeImporterPresenter >> createAggregators [

	| idColumn1 idColumn2 |
	idColumn1 := self idColumn1.
	idColumn2 := self idColumn2.
	^ Array streamContents: [ :stream |
		  aggregators keysAndValuesDo: [ :column :string |
			  (column = idColumn1 or: [ column = idColumn2 ]) ifFalse: [
				  string = #sum
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

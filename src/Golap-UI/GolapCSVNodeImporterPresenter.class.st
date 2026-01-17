Class {
	#name : 'GolapCSVNodeImporterPresenter',
	#superclass : 'GolapCSVImportPresenter',
	#instVars : [
		'idDropList',
		'nameDropList',
		'photoUrlColumnDropList'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'layout' }
GolapCSVNodeImporterPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #columnsTable expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: 'アイテムID' asPresenter width: 80;
				   add: #idDropList expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: 'アイテム名' asPresenter width: 80;
				   add: #nameDropList expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: '評価値' asPresenter width: 80;
				   add: #evaluatorDropList expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: '画像URL' asPresenter width: 80;
				   add: #photoUrlColumnDropList expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'snapshot' }
GolapCSVNodeImporterPresenter >> asJSON [

	^ super asJSON
		  at: 'idDropList' put: idDropList selectedIndex;
		  at: 'nameDropList' put: nameDropList selectedIndex;
		  at: 'photoUrlColumnDropList'
		  put: photoUrlColumnDropList selectedIndex;
		  yourself
]

{ #category : 'accessing' }
GolapCSVNodeImporterPresenter >> availableEvaluators [

	^ Array streamContents: [ :stream |
			  (dataframe notNil and: [ dataframe notEmpty ]) ifTrue: [
					  | row |
					  row := dataframe rowAt: 1.
					  ((row keys copyWithoutAll: {
							    self idColumn.
							    self nameColumn }) select: [ :column |
						   (row at: column) isNumber ]) do: [ :column |
						  stream nextPut: (GolapNodeColumnEvaluator column: column) ] ].
			  stream
				  nextPut: GolapNodeSumEvaluator new;
				  nextPut: GolapNodeMaxEvaluator new;
				  nextPut: GolapNodeAverageEvaluator new ]
]

{ #category : 'operations' }
GolapCSVNodeImporterPresenter >> createAggregators [

	| idColumn nameColumn |
	idColumn := self idColumn.
	nameColumn := self nameColumn.
	^ Array streamContents: [ :stream |
		  aggregators keysAndValuesDo: [ :column :string |
			  (column = idColumn or: [ column = nameColumn ]) ifFalse: [
				  string = #sum
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
GolapCSVNodeImporterPresenter >> defaultNameColumn [

	^ dataframe ifNotNil: [
			  dataframe columnNames
				  detect: [ :column |
					  (dataframe at: 1 at: (dataframe indexOfColumnNamed: column))
						  isString ]
				  ifNone: [ nil ] ]
]

{ #category : 'snapshot' }
GolapCSVNodeImporterPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'idDropList'
		ifPresent: [ :integer | idDropList selectIndex: integer ];
		at: 'nameDropList'
		ifPresent: [ :integer | nameDropList selectIndex: integer ];
		at: 'photoUrlColumnDropList'
		ifPresent: [ :integer | photoUrlColumnDropList selectIndex: integer ]
]

{ #category : 'accessing' }
GolapCSVNodeImporterPresenter >> idColumn [

	^ idDropList selectedItem
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> idColumnChanged [

	self
		updateEvaluatorDropList;
		updatePhotoUrlDropList
]

{ #category : 'initialization' }
GolapCSVNodeImporterPresenter >> initializePresenters [

	super initializePresenters.
	idDropList := self newDropList whenSelectionChangedDo: [
		              self idColumnChanged ].
	nameDropList := self newDropList whenSelectionChangedDo: [
		                self nameColumnChanged ].
	photoUrlColumnDropList := self newDropList whenSelectionChangedDo: [
		                          self photoUrlColumnChanged ]
]

{ #category : 'accessing' }
GolapCSVNodeImporterPresenter >> nameColumn [

	^ nameDropList selectedItem
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> nameColumnChanged [

	self
		updateEvaluatorDropList;
		updatePhotoUrlDropList
]

{ #category : 'accessing' }
GolapCSVNodeImporterPresenter >> photoUrlColumn [

	^ photoUrlColumnDropList selectedItem
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> photoUrlColumnChanged [

	self updateEvaluatorDropList
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> updateIdDropList [

	idDropList
		items: self availableColumns;
		selectIndex: 1
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> updateNameDropList [

	nameDropList
		items: self availableStringColumns;
		selectItem: self defaultNameColumn
]

{ #category : 'updating' }
GolapCSVNodeImporterPresenter >> updatePhotoUrlDropList [

	| selection items |
	selection := photoUrlColumnDropList selectedItem.
	items := self availableStringColumns copyWithoutAll: {
			         self idColumn.
			         self nameColumn }.
	photoUrlColumnDropList items: items.
	(items includes: selection)
		ifTrue: [ photoUrlColumnDropList selectItem: selection ]
		ifFalse: [ photoUrlColumnDropList selectIndex: 1 ]
]

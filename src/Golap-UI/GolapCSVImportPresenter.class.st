Class {
	#name : 'GolapCSVImportPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'columnsTable',
		'evaluatorDropList',
		'aggregators',
		'dataframe'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'testing' }
GolapCSVImportPresenter class >> isAbstract [

	^ self = GolapCSVImportPresenter
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> aggregatorAt: aString put: aGolapDataAggregator [

	aggregators at: aString put: aGolapDataAggregator
]

{ #category : 'snapshot' }
GolapCSVImportPresenter >> asJSON [

	^ {
		  ('columnsTable-selectionIndex' -> columnsTable selectedIndex).
		  ('evaluatorDropList-selectionIndex'
		   -> evaluatorDropList selectedIndex) } asOrderedDictionary
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableAggregatorsFor: aString [

	^ dataframe
		  ifNotNil: [
			  | row |
			  row := dataframe rowAt: 1.
			  (row at: aString ifAbsent: [ nil ]) isNumber
				  ifTrue: [
					  Array streamContents: [ :stream |
						  stream nextPut: #sum.
						  row keysAndValuesDo: [ :column :value |
							  value isNumber ifTrue: [ stream nextPut: column ] ] ] ]
				  ifFalse: [ {  } ] ]
		  ifNil: [ {  } ]
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableColumns [

	^ dataframe ifNotNil: [ dataframe columnNames ] ifNil: [ {  } ]
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableEvaluators [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableStringColumns [

	^ dataframe ifEmpty: [ {  } ] ifNotEmpty: [
			  | row |
			  row := dataframe rowAt: 1.
			  Array streamContents: [ :stream |
					  row keysAndValuesDo: [ :column :value |
						  value isString ifTrue: [ stream nextPut: column ] ] ] ]
]

{ #category : 'operations' }
GolapCSVImportPresenter >> createAggregators [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> dataframe: aDataFrame [

	aDataFrame columnNames copy do: [ :columnName |
		((aDataFrame column: columnName) anySatisfy: [ :value |
			 value isNil or: [ value isFloat and: [ value isFinite not ] ] ])
			ifTrue: [ aDataFrame removeColumn: columnName ] ].
	dataframe := aDataFrame.
	self dataframeChanged
]

{ #category : 'updating' }
GolapCSVImportPresenter >> dataframeChanged [

	self
		updateAggregators;
		updateColumnsTable;
		updateEvaluatorDropList
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> displayAggregator: aString [

	aString = #sum ifTrue: [ ^ '合計' ].
	^ '重み付き平均（重み=' , aString , '）'
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> evaluator [

	^ evaluatorDropList selectedItem
]

{ #category : 'updating' }
GolapCSVImportPresenter >> evaluatorChanged [

	
]

{ #category : 'snapshot' }
GolapCSVImportPresenter >> fromJSON: aDictionary [

	aDictionary
		at: 'columnsTable-selectionIndex'
		ifPresent: [ :integer | columnsTable selectIndex: integer ];
		at: 'evaluatorDropList-selectionIndex'
		ifPresent: [ :integer | evaluatorDropList selectIndex: integer ]
]

{ #category : 'initialization' }
GolapCSVImportPresenter >> initialize [

	super initialize.
	aggregators := Dictionary new.
	dataframe := nil
]

{ #category : 'initialization' }
GolapCSVImportPresenter >> initializePresenters [

	super initializePresenters.
	columnsTable := self newTable
		                beResizable;
		                yourself.
	evaluatorDropList := self newDropList
		                     display: [ :evaluator | evaluator name ];
		                     whenSelectedItemChangedDo: [
			                     self evaluatorChanged ];
		                     yourself
]

{ #category : 'updating' }
GolapCSVImportPresenter >> updateAggregators [

	self availableColumns do: [ :column |
		(self availableAggregatorsFor: column) ifNotEmpty: [
			:availableAggregators |
			aggregators at: column put: availableAggregators first ] ]
]

{ #category : 'updating' }
GolapCSVImportPresenter >> updateColumnsTable [

	columnsTable
		columns: {
				(SpStringTableColumn title: 'カラム名' evaluated: #asString).
				(SpStringTableColumn title: 'データ例' evaluated: [ :column |
							 dataframe ifNotNil: [
										 dataframe ifEmpty: [ '-' ] ifNotEmpty: [
													 (dataframe indexOfColumnNamed: column ifAbsent: [ nil ])
														 ifNotNil: [ :index | dataframe at: 1 at: index ]
														 ifNil: [ '-' ] ] ] ]).
				((SpDropListTableColumn
					  title: 'マージ'
					  evaluated: [ :column | self availableAggregatorsFor: column ])
					 display: [ :item | self displayAggregator: item ];
					 selectedItemChangedAction: [ :column :aggregator |
						 self aggregatorAt: column put: aggregator ];
					 yourself) };
		items: self availableColumns
]

{ #category : 'updating' }
GolapCSVImportPresenter >> updateEvaluatorDropList [

	| selection items |
	selection := evaluatorDropList selectedItem.
	items := self availableEvaluators.
	evaluatorDropList items: items.
	(items includes: selection)
		ifTrue: [ evaluatorDropList selectItem: selection ]
		ifFalse: [ evaluatorDropList selectIndex: 1 ]
]

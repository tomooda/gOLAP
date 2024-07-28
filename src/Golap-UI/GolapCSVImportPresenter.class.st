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

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableAggregatorsFor: aString [

	^ dataframe
		  ifNotNil: [
			  | row |
			  row := dataframe rows first.
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

	^ dataframe ifNotNil: #columnNames ifNil: [ {  } ]
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableEvaluators [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> availableStringColumns [

	^ dataframe rows ifEmpty: [ {  } ] ifNotEmpty: [ :rows |
		  Array streamContents: [ :stream |
			  rows first keysAndValuesDo: [ :column :value |
				  value isString ifTrue: [ stream nextPut: column ] ] ] ]
]

{ #category : 'operations' }
GolapCSVImportPresenter >> createAggregators [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> dataframe: aDataFrame [

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
								 dataframe rows
									 ifEmpty: [ '-' ]
									 ifNotEmpty: [ :rows |
										 rows first at: column ifAbsent: [ '-' ] ] ] ]).
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
GolapCSVImportPresenter >> updateDataframe [

	dataframe := nil.
	self fileReference ifNotNil: [ :ref |
		ref isFile ifTrue: [ dataframe := DataFrame readFromCsv: ref ] ].
	self dataframeChanged
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

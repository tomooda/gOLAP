Class {
	#name : 'GolapCSVImportPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'pathField',
		'changePathButton',
		'columnsTable',
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

{ #category : 'operations' }
GolapCSVImportPresenter >> changePath [

	(StOpenFilePresenter extensions: #( 'csv' ))
		defaultFolder: (self fileReference
				 ifNotNil: [ :ref |
					 ref isFile
						 ifTrue: [ ref parent ]
						 ifFalse: [ ref ] ]
				 ifNil: [ FileLocator documents / 'gOLAP' ]);
		okAction: [ :ref |
			pathField text: ref absolutePath pathString.
			self pathChanged ]
]

{ #category : 'operations' }
GolapCSVImportPresenter >> createAggregators [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapCSVImportPresenter >> dataframeChanged [

	self updateColumnsTable
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> displayAggregator: aString [

	aString = #sum ifTrue: [ ^ '合計' ].
	^ '重み付き平均（重み=' , aString , '）'
]

{ #category : 'accessing' }
GolapCSVImportPresenter >> fileReference [

	^ pathField text trim ifNotEmpty: #asFileReference
]

{ #category : 'updating' }
GolapCSVImportPresenter >> idColumnChanged [
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
	pathField := self newTextInput
		             whenChangedDo: [ self pathChanged ];
		             whenSubmitDo: [ self pathChanged ];
		             yourself.
	changePathButton := self newButton
		                    icon: (self iconNamed: #open);
		                    action: [ self changePath ];
		                    yourself.
	columnsTable := self newTable
		                beResizable;
		                yourself.
	self whenBuiltDo: [
		pathField text:
			(FileLocator documents / 'gOLAP') asFileReference absolutePath
				pathString ]
]

{ #category : 'operations' }
GolapCSVImportPresenter >> loadInto: aGolapModel [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapCSVImportPresenter >> nameColumnChanged [
]

{ #category : 'updating' }
GolapCSVImportPresenter >> pathChanged [

	self updateDataframe
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

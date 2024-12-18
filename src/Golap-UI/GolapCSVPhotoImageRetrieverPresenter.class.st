Class {
	#name : 'GolapCSVPhotoImageRetrieverPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'retriever',
		'changeCsvButton',
		'idColumnTable',
		'photoColumnTable',
		'urlPrefixField',
		'nameLabel',
		'urlPostfixField',
		'openPreviewButton',
		'defaultIdColumn',
		'defaultPhotoColumn'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'layout' }
GolapCSVPhotoImageRetrieverPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #changeCsvButton expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: #idColumnTable;
				   add: #photoColumnTable;
				   yourself);
		  add: (SpBoxLayout newHorizontal
				   vAlignEnd;
				   add: #urlPrefixField;
				   add: #nameLabel expand: false;
				   add: #urlPostfixField;
				   add: #openPreviewButton expand: false;
				   yourself)
		  height: self buttonHeight * 1.5;
		  yourself
]

{ #category : 'examples' }
GolapCSVPhotoImageRetrieverPresenter class >> example [

	^ self new open
]

{ #category : 'instance creation' }
GolapCSVPhotoImageRetrieverPresenter class >> on: aGolapCSVPhotoImageRetriever [

	^ self new
		  retriever: aGolapCSVPhotoImageRetriever;
		  yourself
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> csvRef: aFileReference [

	| columnNames idColumn photoColumn |
	retriever csvRef ~= aFileReference ifTrue: [
		retriever csvRef: aFileReference ].
	columnNames := retriever dataframe
		               ifNotNil: #columnNames
		               ifNil: [ #(  ) ].
	idColumn := idColumnTable selectedItem ifNil: [ defaultIdColumn ].
	photoColumn := photoColumnTable selectedItem ifNil: [
		               defaultPhotoColumn ].
	idColumnTable
		unselectAll;
		items: columnNames.
	(columnNames includes: idColumn)
		ifTrue: [ idColumnTable selectItem: idColumn ]
		ifFalse: [ idColumnTable selectIndex: 1 ].
	photoColumnTable
		unselectAll;
		items: columnNames.
	(columnNames includes: photoColumn)
		ifTrue: [ photoColumnTable selectItem: photoColumn ]
		ifFalse: [ photoColumnTable selectIndex: 1 ].
	urlPrefixField enable.
	urlPostfixField enable.
	openPreviewButton enable
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> dataframe [

	^ retriever ifNotNil: #dataframe
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> initialize [

	super initialize.
	retriever := GolapCSVPhotoImageRetriever new
]

{ #category : 'initialization' }
GolapCSVPhotoImageRetrieverPresenter >> initializePresenters [

	changeCsvButton := self newButton
		                   icon: (self iconNamed: #open);
		                   label: 'CSVファイル';
		                   action: [ self openCsv ];
		                   yourself.
	idColumnTable := self newTable
		                 disable;
		                 addColumn: (SpStringTableColumn
				                  title: 'IDカラム名'
				                  evaluated: [ :column | column asString ]);
		                 addColumn:
			                 (SpStringTableColumn
				                  title: '例'
				                  evaluated: [ :column |
					                  self dataframe ifNotNil: [ :dataframe |
							                  (dataframe
								                   at: 1
								                   at: (dataframe indexOfColumnNamed: column))
								                  asString ] ]);
		                 whenSelectedItemChangedDo: [ :column |
			                 retriever ifNotNil: [ retriever idColumn: column ] ];
		                 yourself.
	photoColumnTable := self newTable
		                    disable;
		                    addColumn: (SpStringTableColumn
				                     title: '画像カラム名'
				                     evaluated: [ :column | column asString ]);
		                    addColumn:
			                    (SpStringTableColumn
				                     title: '例'
				                     evaluated: [ :column |
					                     self dataframe ifNotNil: [ :dataframe |
							                     (dataframe
								                      at: 1
								                      at:
									                      (dataframe indexOfColumnNamed: column))
								                     asString ] ]);
		                    whenSelectedItemChangedDo: [ :column |
			                    retriever ifNotNil: [
					                    retriever photoColumn: column ].
			                    nameLabel label:
					                    '${' , (column ifNil: [ '' ]) , '}' ];
		                    yourself.
	urlPrefixField := self newTextInput
		                  disable;
		                  placeholder: 'ベースURL';
		                  whenTextChangedDo: [ :prefix |
			                  retriever ifNotNil: [
					                  retriever urlPrefix: prefix ] ];
		                  yourself.
	nameLabel := self newLabel
		             label: '${}';
		             yourself.
	urlPostfixField := self newTextInput
		                   disable;
		                   placeholder: 'URL拡張子など';
		                   whenTextChangedDo: [ :postfix |
			                   retriever ifNotNil: [
					                   retriever urlPostfix: postfix ] ];
		                   yourself.
	openPreviewButton := self newButton
		                     icon: (self iconNamed: #smallFind);
		                     action: [ self openPreview ];
		                     yourself
]

{ #category : 'initialization' }
GolapCSVPhotoImageRetrieverPresenter >> initializeWindow: aSpWindow [

	super initializeWindow: aSpWindow.
	aSpWindow initialExtent: 600 @ 300
]

{ #category : 'initialization' }
GolapCSVPhotoImageRetrieverPresenter >> openCsv [

	StOpenFilePresenter new
		defaultFolder: FileLocator documents / 'gOLAP';
		extensions: #( 'csv' );
		okAction: [ :ref | self csvRef: ref ];
		open
]

{ #category : 'operations' }
GolapCSVPhotoImageRetrieverPresenter >> openPreview [

	self dataframe ifNotNil: [ :dataframe |
		1 to: (10 min: dataframe numberOfRows) do: [ :row |
			([
			 self retriever retrieveImageNamed: (self dataframe
					  at: row
					  at:
					  (self dataframe indexOfColumnNamed:
						   photoColumnTable selectedItem)) ]
				 on: Error
				 do: [ :ex | ex return: nil ]) ifNotNil: [ :form |
				form asPresenter open title: 'Preview'.
				^ form ] ] ]
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> retriever [

	^ retriever
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> retriever: aGolapCSVPhotoImageRetriever [

	retriever := aGolapCSVPhotoImageRetriever.
	defaultIdColumn := retriever idColumn.
	idColumnTable selectItem: defaultIdColumn.
	defaultPhotoColumn := retriever photoColumn.
	photoColumnTable selectItem: defaultPhotoColumn.
	urlPrefixField text: retriever urlPrefix.
	urlPostfixField text: retriever urlPostfix.
	self csvRef: retriever csvRef
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> title [

	^ '画像テーブル設定'
]

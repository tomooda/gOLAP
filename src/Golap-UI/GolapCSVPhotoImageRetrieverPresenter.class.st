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
		'openPreviewButton'
	],
	#category : 'Golap-UI-PhotoImageRetriever',
	#package : 'Golap-UI',
	#tag : 'PhotoImageRetriever'
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
				   add: #urlPrefixField;
				   add: #nameLabel expand: false;
				   add: #urlPostfixField;
				   add: #openPreviewButton expand: false;
				   yourself)
		  expand: false;
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

	retriever csvRef: aFileReference.
	idColumnTable
		unselectAll;
		items: retriever dataframe columnNames;
		selectIndex: 1.
	photoColumnTable
		unselectAll;
		items: retriever dataframe columnNames;
		selectIndex: 1
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
		                   label: 'Choose CSV';
		                   action: [ self openCsv ];
		                   yourself.
	idColumnTable := self newTable
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
		                  whenTextChangedDo: [ :prefix |
			                  retriever ifNotNil: [
					                  retriever urlPrefix: prefix ] ];
		                  yourself.
	nameLabel := self newLabel
		             label: '${}';
		             yourself.
	urlPostfixField := self newTextInput
		                   whenTextChangedDo: [ :postfix |
			                   retriever ifNotNil: [
					                   retriever urlPrefix: postfix ] ];
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
	idColumnTable selectItem: retriever idColumn.
	photoColumnTable selectItem: retriever photoColumn.
	urlPrefixField text: retriever urlPrefix.
	urlPostfixField text: retriever urlPostfix
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetrieverPresenter >> title [

	^ '画像テーブル設定'
]

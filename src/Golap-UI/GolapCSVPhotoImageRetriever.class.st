Class {
	#name : 'GolapCSVPhotoImageRetriever',
	#superclass : 'GolapPhotoImageRetriever',
	#instVars : [
		'csvRef',
		'dataframe',
		'idColumn',
		'photoColumn',
		'urlCache',
		'urlPostfix',
		'urlPrefix'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapCSVPhotoImageRetriever class >> for: aGolapItemInfoRetriever [

	^ self new
		  initializeWith: aGolapItemInfoRetriever;
		  yourself
]

{ #category : 'private' }
GolapCSVPhotoImageRetriever >> commit: aGolapCSVPhotoImageRetriever [

	csvRef := aGolapCSVPhotoImageRetriever csvRef.
	dataframe := aGolapCSVPhotoImageRetriever dataframe.
	idColumn := aGolapCSVPhotoImageRetriever idColumn.
	photoColumn := aGolapCSVPhotoImageRetriever photoColumn.
	urlPrefix := aGolapCSVPhotoImageRetriever urlPrefix.
	urlPostfix := aGolapCSVPhotoImageRetriever urlPostfix
]

{ #category : 'user interface' }
GolapCSVPhotoImageRetriever >> configPresenter [

	^ GolapCSVPhotoImageRetrieverPresenter on: self
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> csvRef [

	^ csvRef
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> csvRef: aFileReference [

	csvRef := aFileReference.
	self csvRefChanged
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> csvRefChanged [
	self updateDataframe
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> dataframe [

	^ dataframe
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> dataframe: aDataFrame [

	dataframe := aDataFrame.
	self dataframeChanged
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> dataframeChanged [

	self
		updateIdColumn;
		updatePhotoColumn;
		flushUrlCache
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> flushUrlCache [

	urlCache removeAll
]

{ #category : 'testing' }
GolapCSVPhotoImageRetriever >> hasConfigPresenter [

	^ true
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> idColumn [

	^ idColumn
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> idColumn: aStringOrNil [

	idColumn := aStringOrNil.
	self idColumnChanged
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> idColumnChanged [

	self flushUrlCache
]

{ #category : 'initialization' }
GolapCSVPhotoImageRetriever >> initialize [

	super initialize.
	urlPrefix := ''.
	urlPostfix := ''.
	urlCache := Dictionary new
]

{ #category : 'initialization' }
GolapCSVPhotoImageRetriever >> initializeWith: aGolapItemInfoRetriever [

	({ #serverConfig. #query. #golapServerUrl. #imageRepositoryUrl }
		 allSatisfy: [ :selector |
		 aGolapItemInfoRetriever respondsTo: selector ]) ifTrue: [
		urlPrefix := aGolapItemInfoRetriever imageRepositoryUrl asString.
		urlPostfix := ''.
		aGolapItemInfoRetriever serverConfig
			at: 'itemAttFile'
			ifPresent: [ :itemAttFile |
				itemAttFile
					at: 'imageField'
					ifPresent: [ :imageField | photoColumn := imageField ] ].
		aGolapItemInfoRetriever query at: 'query' ifPresent: [ :q |
			q at: 'granularity' ifPresent: [ :granularity |
				granularity
					at: 'node'
					ifPresent: [ :nodeGranularity | idColumn := nodeGranularity ] ] ] ]
]

{ #category : 'testing' }
GolapCSVPhotoImageRetriever >> isAvailable [

	^  dataframe notNil and: [
(dataframe columnNames includes: idColumn)
			  and: [  dataframe columnNames includes: photoColumn ] ]
]

{ #category : 'enumerating' }
GolapCSVPhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	^ (urlCache at: aGolapNode id ifAbsentPut: [
		   | id idColumnIndex photoColumnIndex urls |
		   id := aGolapNode id.
		   idColumnIndex := dataframe indexOfColumnNamed: idColumn.
		   photoColumnIndex := dataframe indexOfColumnNamed: photoColumn.
		   urls := Set new.
		   1 to: dataframe numberOfRows do: [ :index |
			   (dataframe at: index at: idColumnIndex) = id ifTrue: [
				   urls add: (dataframe at: index at: photoColumnIndex) ] ].
		   urls asSortedCollection asArray ]) do: aBlock
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> order [

	^ 90
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> photoColumn [

	^ photoColumn
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> photoColumn: aStringOrNil [

	photoColumn := aStringOrNil.
	self photoColumnChanged
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> photoColumnChanged [

	self flushUrlCache
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> retrieveImageNamed: aString [

	^ [
	  ImageReadWriter formFromStream:
		  (urlPrefix , aString , urlPostfix) asZnUrl retrieveBinaryContents
			  readStream ]
		  on: Exception
		  do: [ :ex | ex return: nil ]
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> shortDescription [

	^ 'CSVファイル ' , (csvRef ifNil: [ '(未設定)' ] ifNotNil: #basename) , ' '
	  , (idColumn ifNil: [ '(IDカラム未設定)' ]) , '->'
	  , (photoColumn ifNil: [ '(画像カラム未設定)' ])
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> updateDataframe [

	csvRef ifNotNil: [
		csvRef isFile ifTrue: [
			self dataframe: (DataFrame readFromCsv: csvRef) ] ]
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> updateIdColumn [

	dataframe ifNotNil: [
		(dataframe columnNames includes: idColumn) ifFalse: [
			self idColumn: nil ] ]
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> updatePhotoColumn [

	dataframe ifNotNil: [
		(dataframe columnNames includes: photoColumn) ifFalse: [
			self photoColumn: nil ] ]
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> urlPostfix [

	^ urlPostfix
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> urlPostfix: aString [

	urlPostfix := aString
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> urlPrefix [

	^ urlPrefix
]

{ #category : 'accessing' }
GolapCSVPhotoImageRetriever >> urlPrefix: aString [

	urlPrefix := aString
]

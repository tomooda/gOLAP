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
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

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

{ #category : 'testing' }
GolapCSVPhotoImageRetriever >> isAvailable [

	^  dataframe notNil and: [
(dataframe columnNames includes: idColumn)
			  and: [  dataframe columnNames includes: photoColumn ] ]
]

{ #category : 'accessing' }
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
		  on: Error
		  do: [ :ex | ex return: nil ]
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> updateDataframe [

	csvRef ifNotNil: [
		csvRef isFile ifTrue: [
			self dataframe: (DataFrame readFromCsv: csvRef) ] ].
	self dataframeChanged
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> updateIdColumn [

	self idColumn: nil
]

{ #category : 'updating' }
GolapCSVPhotoImageRetriever >> updatePhotoColumn [

	self photoColumn: nil
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

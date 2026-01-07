Class {
	#name : 'GolapAttributePhotoImageRetriever',
	#superclass : 'GolapPhotoImageRetriever',
	#instVars : [
		'photoColumn',
		'availableColumns'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapAttributePhotoImageRetriever class >> for: aGolapItemInfoRetriever [

	^ [
	  self new
		  availableColumns: aGolapItemInfoRetriever availableColumns;
		  photoColumn: aGolapItemInfoRetriever photoUrlColumn;
		  yourself ]
		  on: Error
		  do: [ :ex | ex return: nil ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever class >> tag [

	^ 'attribute'
]

{ #category : 'snapshot' }
GolapAttributePhotoImageRetriever >> asJSON [

	| json |
	json := super asJSON.
	photoColumn ifNotNil: [ json at: 'photoColumn' put: photoColumn ].
	availableColumns ifNotNil: [
		json at: 'availableColumns' put: availableColumns ].
	^ json
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> availableColumns [

	^ availableColumns
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> availableColumns: anArrayOfString [

	availableColumns := anArrayOfString.
	(availableColumns includes: photoColumn) ifFalse: [
		photoColumn := nil ]
]

{ #category : 'private' }
GolapAttributePhotoImageRetriever >> commit: copy [

	photoColumn := copy photoColumn.
	availableColumns := copy availableColumns
]

{ #category : 'user interface' }
GolapAttributePhotoImageRetriever >> configPresenter [

	^ GolapAttributePhotoImageRetrieverPresenter on: self
]

{ #category : 'snapshot' }
GolapAttributePhotoImageRetriever >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'photoColumn' ifPresent: [ :string | photoColumn := string ];
		at: 'availableColumns'
		ifPresent: [ :array | availableColumns := array ]
]

{ #category : 'testing' }
GolapAttributePhotoImageRetriever >> hasConfigPresenter [

	^ true
]

{ #category : 'initialization' }
GolapAttributePhotoImageRetriever >> initialize [

	super initialize.
	photoColumn := nil.
	availableColumns := Array new
]

{ #category : 'testing' }
GolapAttributePhotoImageRetriever >> isAvailable [

	^ availableColumns includes: photoColumn
]

{ #category : 'enumerating' }
GolapAttributePhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	aGolapNode data
		at: photoColumn
		ifPresent: [ :name | name isString ifTrue: [ aBlock value: name ] ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> order [

	^ 0
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> photoColumn [

	^ photoColumn
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> photoColumn: aString [

	photoColumn := aString.
	(photoColumn notNil and: [
		 (availableColumns includes: photoColumn) not ]) ifTrue: [
		availableColumns := availableColumns copyWith: photoColumn ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> retrieveImageNamed: aString [

	^ [
	  ImageReadWriter formFromStream:
		  aString asUrl retrieveBinaryContents readStream ]
		  on: Exception
		  do: [ :ex | ex return: nil ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> shortDescription [

	^ 'アイテム属性 ' , (photoColumn ifNil: [ '(未設定)' ])
]

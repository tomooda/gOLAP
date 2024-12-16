Class {
	#name : 'GolapAttributePhotoImageRetriever',
	#superclass : 'GolapPhotoImageRetriever',
	#instVars : [
		'photoColumn',
		'availableColumns'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
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

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	aGolapNode data
		at: photoColumn
		ifPresent: [ :name | name isString ifTrue: [ aBlock value: name ] ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> order [

	^ 1
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
		  on: Error
		  do: [ :ex | ex return: nil ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetriever >> shortDescription [

	^ 'アイテム属性 ' , (photoColumn ifNil: [ '(未設定)' ])
]

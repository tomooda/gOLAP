Class {
	#name : 'GolapPhotoImageRetriever',
	#superclass : 'Object',
	#instVars : [
		'enabled'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever class >> cacheDirectory [

	^ (self golapDirectory / 'imagecache')
		  ensureCreateDirectory;
		  yourself
]

{ #category : 'accessing' }
GolapPhotoImageRetriever class >> classForJSON: aDictionary [

	| tag |
	tag := aDictionary at: 'tag' ifAbsent: [ ^ nil ].
	self allSubclassesDo: [ :subclass |
			(subclass isAbstract not and: [ subclass tag = tag ]) ifTrue: [
				^ subclass ] ].
	^ nil
]

{ #category : 'utilities' }
GolapPhotoImageRetriever class >> clearCache [

	self cacheDirectory ensureDeleteAllChildren
]

{ #category : 'instance creation' }
GolapPhotoImageRetriever class >> for: aGolapItemInfoRetriever [

	^ self subclassResponsibility
]

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever class >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'testing' }
GolapPhotoImageRetriever class >> isAbstract [

	^ self = GolapPhotoImageRetriever
]

{ #category : 'accessing' }
GolapPhotoImageRetriever class >> tag [

	^ self subclassResponsibility
]

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever >> cacheAt: aString ifAbsent: errorBlock [

	| ref |
	(ref := self cacheDirectory
	        / (aString , '.png' copyReplaceAll: '/' with: '_')) isFile
		ifTrue: [
				ref binaryReadStreamDo: [ :stream |
						^ [ PNGReadWriter formFromStream: stream ]
							  on: Exception
							  do: [ :ex | ex return: nil ] ] ]
		ifFalse: [ ^ errorBlock value ].
	^ nil
]

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever >> cacheAt: aString ifAbsentPut: errorBlock [

	| ref |
	(ref := self cacheDirectory
	        / (aString , '.png' copyReplaceAll: '/' with: '_')) isFile
		ifTrue: [
			ref binaryReadStreamDo: [ :stream |
				^ [ PNGReadWriter formFromStream: stream ]
					  on: Exception
					  do: [ :ex | ex return: nil ] ] ]
		ifFalse: [
			errorBlock value ifNotNil: [ :form |
				form isForm ifTrue: [
					ref
						ensureDelete;
						binaryWriteStreamDo: [ :stream |
							[ PNGReadWriter putForm: form onStream: stream ]
								on: Error
								do: [ :ex | ref ensureDelete ] ].
					^ form ] ] ].
	^ nil
]

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever >> cacheDirectory [
	^ self class cacheDirectory
]

{ #category : 'private' }
GolapPhotoImageRetriever >> commit: copy [

	^ self subclassResponsibility
]

{ #category : 'user interface' }
GolapPhotoImageRetriever >> configPresenter [

	^ nil
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> enabled [

	^ enabled = true
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> enabled: aBoolean [

	enabled := aBoolean = true
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'testing' }
GolapPhotoImageRetriever >> hasConfigPresenter [

	^ false
]

{ #category : 'initialization' }
GolapPhotoImageRetriever >> initialize [

	super initialize.
	enabled := true
]

{ #category : 'testing' }
GolapPhotoImageRetriever >> isAvailable [

	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapPhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> order [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> photoimageFor: aGolapNode [

	self isAvailable ifTrue: [
		self namesFor: aGolapNode do: [ :name |
			(self cacheAt: name ifAbsentPut: [ self retrieveImageNamed: name ])
				ifNotNil: [ :form | ^ form ] ] ].
	^ nil
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> photoimagesFor: aGolapNode [

	^ Array streamContents: [ :stream |
		  self isAvailable ifTrue: [
			  self namesFor: aGolapNode do: [ :name |
				  (self
					   cacheAt: name
					   ifAbsentPut: [ self retrieveImageNamed: name ]) ifNotNil: [
					  :form | stream nextPut: form ] ] ] ]
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> retrieveImageNamed: aString [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> shortDescription [

	^ self subclassResponsibility
]

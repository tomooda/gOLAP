Class {
	#name : 'GolapPhotoImageRetriever',
	#superclass : 'Object',
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapPhotoImageRetriever class >> for: aGolapItemInfoRetriever [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapPhotoImageRetriever class >> isAbstract [

	^ self = GolapPhotoImageRetriever
]

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever >> cacheAt: aString ifAbsentPut: errorBlock [

	| ref |
	(ref := self cacheDirectory / aString withExtension: 'png') isFile
		ifTrue: [
			ref
				binaryReadStreamDo: [ :stream |
					^ [ PNGReadWriter formFromStream: stream ]
						  on: Error
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

	^ (FileLocator documents / 'gOLAP' / 'imagecache')
		  ensureCreateDirectory;
		  yourself
]

{ #category : 'private' }
GolapPhotoImageRetriever >> commit: copy [

	^ self subclassResponsibility
]

{ #category : 'user interface' }
GolapPhotoImageRetriever >> configPresenter [

	^ nil
]

{ #category : 'testing' }
GolapPhotoImageRetriever >> hasConfigPresenter [

	^ false
]

{ #category : 'accessing-cache' }
GolapPhotoImageRetriever >> imagecacheDirectory [

	^ (FileLocator documents / 'gOLAP' / 'imagecache')
		  ensureCreateDirectory;
		  yourself
]

{ #category : 'testing' }
GolapPhotoImageRetriever >> isAvailable [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> order [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapPhotoImageRetriever >> photoimageFor: aGolapNode [

	^ (self photoimagesFor: aGolapNode)
		  ifNotEmpty: #first
		  ifEmpty: [ nil ]
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

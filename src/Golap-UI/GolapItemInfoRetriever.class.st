Class {
	#name : 'GolapItemInfoRetriever',
	#superclass : 'Object',
	#instVars : [
		'photoimageRetrievers'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'accessing' }
GolapItemInfoRetriever class >> classForJSON: aDictionary [

	| tag |
	tag := aDictionary at: 'tag' ifAbsent: [ ^ nil ].
	self allSubclassesDo: [ :subclass |
			(subclass isAbstract not and: [ subclass tag = tag ]) ifTrue: [
				^ subclass ] ].
	^ nil
]

{ #category : 'testing' }
GolapItemInfoRetriever class >> isAbstract [

	^ self = GolapItemInfoRetriever
]

{ #category : 'accessing' }
GolapItemInfoRetriever class >> tag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> attributeNames [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> availablePhotoimageRetrievers [

	^ ((Array streamContents: [ :stream |
		    GolapPhotoImageRetriever allSubclassesDo: [ :class |
			    class isAbstract ifFalse: [
				    (class for: self) ifNotNil: [ :retriever |
					    stream nextPut: retriever ] ] ] ]) asSortedCollection:
		   #order ascending) asArray
]

{ #category : 'operations' }
GolapItemInfoRetriever >> canFlushProductDataCache [

	^ self subclassResponsibility
]

{ #category : 'defaults' }
GolapItemInfoRetriever >> defaultPhotoimageRetrievers [

	^ self availablePhotoimageRetrievers
]

{ #category : 'logging' }
GolapItemInfoRetriever >> flushImageRetrieversLog [

	self photoimageRetrievers select: #isAvailable thenDo: #flushLog
]

{ #category : 'operations' }
GolapItemInfoRetriever >> flushProductDataCache [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapItemInfoRetriever >> hasPhotoImage [

	^ self photoimageRetrievers anySatisfy: #isAvailable
]

{ #category : 'instance creation' }
GolapItemInfoRetriever >> newRetrieveApiClient [

	^ self subclassResponsibility
]

{ #category : 'logging' }
GolapItemInfoRetriever >> openImageRetrieversLog [

	self photoimageRetrievers select: #isAvailable thenDo: [ :retriever |
			retriever log ifNotEmpty: [ :log |
					(SpTextPresenter new
						 text: log;
						 open) title: 'log' ] ]
]

{ #category : 'operations' }
GolapItemInfoRetriever >> photoimageFor: aGolapNode [

	self photoimageRetrievers do: [ :retriever |
		(retriever photoimageFor: aGolapNode) ifNotNil: [ :image | ^ image ] ].
	^ nil
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageRetrievers [

	^ photoimageRetrievers ifNil: [
		  photoimageRetrievers := self defaultPhotoimageRetrievers ]
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageRetrievers: anArrayOfGolapPhotoImageRetriever [

	photoimageRetrievers := anArrayOfGolapPhotoImageRetriever
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageRetrieversConfigPresenter [

	^ GolapPhotoImageRetrieversPresenter on: self
]

{ #category : 'operations' }
GolapItemInfoRetriever >> productDataAt: aString forAll: aCollectionOfGolapNode [

	^ self productDataAt: aString forAll: aCollectionOfGolapNode interimBlock: nil
]

{ #category : 'operations' }
GolapItemInfoRetriever >> productDataAt: aString forAll: aCollectionOfGolapNode interim: aBlock [

	^ self subclassResponsibility
]

{ #category : 'operations' }
GolapItemInfoRetriever >> productDataFor: aGolapNode [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> serverConfig [

	^ nil
]

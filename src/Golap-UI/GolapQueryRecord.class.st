Class {
	#name : 'GolapQueryRecord',
	#superclass : 'Object',
	#traits : 'THiDePersistency',
	#classTraits : 'THiDePersistency classTrait',
	#instVars : [
		'#query => HiDePersistencySlot loader: #loadQuery',
		'#result => HiDePersistencySlot loader: #loadResult',
		'#thumbnail => HiDePersistencySlot loader: #loadThumbnail',
		'#comment => HiDePersistencySlot loader: #loadComment'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'accessing' }
GolapQueryRecord >> comment [

	^ comment
]

{ #category : 'accessing' }
GolapQueryRecord >> comment: aString [

	comment := aString ifNotNil: [ aString asString ]
]

{ #category : 'testing' }
GolapQueryRecord >> hasTag: aString [

	^ hideMetadata hasTag: aString
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideLoad: aFileReference storage: aHiDeStorage [

	self
		loadQuery: aFileReference;
		loadResult: aFileReference;
		loadThumbnail: aFileReference;
		loadComment: aFileReference
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideSave: aFileReference storage: aHiDeStorage [

	self
		saveQuery: aFileReference;
		saveResult: aFileReference;
		saveThumbnail: aFileReference;
		saveComment: aFileReference
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideUpdateMetadataStorage: aHiDeStorage [

	
]

{ #category : 'testing' }
GolapQueryRecord >> includesSubstring: aString [

	hideStorage ifNotNil: [
		hideStorage
			chronicleFileReferenceFor: hideMetadata
			do: [ :baseRef |
				(baseRef filesMatching: '*.json')
				, (baseRef filesMatching: '*.txt') do: [ :ref |
					ref readStreamDo: [ :stream |
						(stream upToEnd includesSubstring: aString) ifTrue: [ ^ true ] ] ] ] ].
	^ false
]

{ #category : 'initialization' }
GolapQueryRecord >> initialize [

	self class initializeSlots: self.
	super initialize.
	self initializeHideMetadata
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadComment [

	hideStorage chronicleFileReferenceFor: hideMetadata do: [ :ref |
		self loadComment: ref.
		^ self ].
	^ nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadComment: aFileReference [

	aFileReference / 'comment.txt' ifExists: [ :ref |
		ref readStreamDo: [ :stream |
			comment := stream upToEnd.
			^ self ] ].
	comment := nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadQuery [

	hideStorage chronicleFileReferenceFor: hideMetadata do: [ :ref |
		self loadQuery: ref.
		^ self ].
	^ nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadQuery: aFileReference [

	aFileReference / 'query.json' ifExists: [ :ref |
		ref readStreamDo: [ :stream |
			query := (GolapQueryJSONReaderWriter on: stream) next.
			^ self ] ].
	query := nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadResult [

	hideStorage chronicleFileReferenceFor: hideMetadata do: [ :ref |
		self loadResult: ref.
		^ self ].
	^ nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadResult: aFileReference [

	aFileReference / 'result.csv' ifExists: [ :ref |
		ref readStreamDo: [ :stream |
			result := stream upToEnd.
			^ self ] ].
	result := nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadThumbnail [

	hideStorage chronicleFileReferenceFor: hideMetadata do: [ :ref |
		self loadThumbnail: ref.
		^ self ].
	^ nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadThumbnail: aFileReference [

	aFileReference / 'thumbnail.png' ifExists: [ :ref |
		ref binaryReadStreamDo: [ :stream |
			thumbnail := PNGReadWriter formFromStream: stream.
			^ self ] ].
	thumbnail := nil
]

{ #category : 'accessing' }
GolapQueryRecord >> query [

	^ query
]

{ #category : 'accessing' }
GolapQueryRecord >> query: aHiDeSyntaxDictionary [

	query := aHiDeSyntaxDictionary
]

{ #category : 'accessing' }
GolapQueryRecord >> result [

	^ result
]

{ #category : 'accessing' }
GolapQueryRecord >> result: aString [

	result := aString
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveComment: aFileReference [

	comment ifNotNil: [
		(aFileReference / 'comment.txt')
			ensureDelete;
			writeStreamDo: [ :stream | stream nextPutAll: comment ] ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveQuery: aFileReference [

	query ifNotNil: [
		(aFileReference / 'query.json')
			ensureDelete;
			writeStreamDo: [ :stream |
				stream nextPutAll: (GolapQueryJSONReaderWriter toStringPretty: query) ] ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveResult: aFileReference [

	result ifNotNil: [
		(aFileReference / 'result.csv')
			ensureDelete;
			writeStreamDo: [ :stream | stream nextPutAll: result ] ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveThumbnail: aFileReference [

	thumbnail ifNotNil: [
		(aFileReference / 'thumbnail.png')
			ensureDelete;
			binaryWriteStreamDo: [ :stream |
				PNGReadWriter putForm: thumbnail onStream: stream ] ]
]

{ #category : 'accessing' }
GolapQueryRecord >> tags [

	^ hideMetadata tags
]

{ #category : 'accessing' }
GolapQueryRecord >> tags: aCollectionOfString [

	hideMetadata tags: aCollectionOfString
]

{ #category : 'accessing' }
GolapQueryRecord >> thumbnail [

	^ thumbnail
]

{ #category : 'accessing' }
GolapQueryRecord >> thumbnail: aForm [

	thumbnail := aForm
]

{ #category : 'accessing' }
GolapQueryRecord >> url [

	^ hideMetadata at: 'url'
]

{ #category : 'accessing' }
GolapQueryRecord >> url: aString [

	hideMetadata at: 'url' put: aString
]

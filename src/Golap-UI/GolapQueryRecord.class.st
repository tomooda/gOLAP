Class {
	#name : 'GolapQueryRecord',
	#superclass : 'Object',
	#traits : 'THiDePersistency',
	#classTraits : 'THiDePersistency classTrait',
	#instVars : [
		'#query => HiDePersistencySlot loader: #loadQuery',
		'#graph => HiDePersistencySlot loader: #loadGraph',
		'#thumbnail => HiDePersistencySlot loader: #loadThumbnail',
		'#comment => HiDePersistencySlot loader: #loadComment'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'hideho-operations' }
GolapQueryRecord >> asJSONString [

	^ GolapQueryJSONReaderWriter toStringPretty: query
]

{ #category : 'accessing' }
GolapQueryRecord >> comment [

	^ comment
]

{ #category : 'accessing' }
GolapQueryRecord >> comment: aString [

	comment := aString ifNotNil: [ aString asString ]
]

{ #category : 'accessing' }
GolapQueryRecord >> graph [

	^ graph
]

{ #category : 'accessing' }
GolapQueryRecord >> graph: anOrderedDictionary [

	graph := anOrderedDictionary
]

{ #category : 'testing' }
GolapQueryRecord >> hasTag: aString [

	^ hideMetadata hasTag: aString
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideDuplicate [

	| duplicate |
	duplicate := self copy.
	duplicate hideMetadata
		identity: nil;
		timestamp: DateAndTime now.
	hideStorage chronicleSave: duplicate.
	^ duplicate
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideLoad: aFileReference [

	self
		loadQuery: aFileReference;
		loadGraph: aFileReference;
		loadThumbnail: aFileReference;
		loadComment: aFileReference
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideSave: aFileReference [

	self
		saveQuery: aFileReference;
		saveGraph: aFileReference;
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

	self hideBaseDirectoryDo: [ :ref | self loadComment: ref ]
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
GolapQueryRecord >> loadGraph [

	self hideBaseDirectoryDo: [ :ref | self loadGraph: ref ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadGraph: aFileReference [

	aFileReference / 'graph.json' ifExists: [ :ref |
		ref readStreamDo: [ :stream |
			graph := (GolapQueryJSONReaderWriter on: stream) next.
			^ self ] ].
	graph := nil
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadQuery [

	self hideBaseDirectoryDo: [ :ref | self loadQuery: ref ]
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
GolapQueryRecord >> loadThumbnail [

	self hideBaseDirectoryDo: [ :ref | self loadThumbnail: ref ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> loadThumbnail: aFileReference [

	aFileReference / 'thumbnail.png' ifExists: [ :ref |
		ref binaryReadStreamDo: [ :stream |
			thumbnail := PNGReadWriter formFromStream: stream.
			^ self ] ].
	thumbnail := nil
]

{ #category : 'printing' }
GolapQueryRecord >> printOn: aStream [

	aStream nextPutAll: self asJSONString
]

{ #category : 'accessing' }
GolapQueryRecord >> query [

	^ query
]

{ #category : 'accessing' }
GolapQueryRecord >> query: aHiDeSyntaxDictionary [

	query := aHiDeSyntaxDictionary
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveComment: aFileReference [

	comment ifNotNil: [
		(aFileReference / 'comment.txt')
			ensureDelete;
			writeStreamDo: [ :stream | stream nextPutAll: comment ] ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveGraph: aFileReference [

	graph ifNotNil: [
		(aFileReference / 'graph.json')
			ensureDelete;
			writeStreamDo: [ :stream | STONJSON put: graph onStream: stream ] ]
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> saveQuery: aFileReference [

	query ifNotNil: [
		(aFileReference / 'query.json')
			ensureDelete;
			writeStreamDo: [ :stream |
				stream nextPutAll: self asJSONString ] ]
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
GolapQueryRecord >> timestampString [

	| timestamp |
	timestamp := self hideMetadata timestamp.
	^ String streamContents: [ :stream |
		  timestamp year printOn: stream base: 10 nDigits: 4.
		  stream nextPut: $/.
		  timestamp month printOn: stream base: 10 nDigits: 2.
		  stream nextPut: $/.
		  timestamp dayOfMonth printOn: stream base: 10 nDigits: 2.
		  stream space.
		  timestamp hour printOn: stream base: 10 nDigits: 2.
		  stream nextPut: $:.
		  timestamp minute printOn: stream base: 10 nDigits: 2.
		  stream nextPut: $:.
		  timestamp second printOn: stream base: 10 nDigits: 2 ]
]

{ #category : 'accessing' }
GolapQueryRecord >> url [

	^ hideMetadata at: 'url'
]

{ #category : 'accessing' }
GolapQueryRecord >> url: aString [

	hideMetadata at: 'url' put: aString
]

Class {
	#name : 'GolapQueryRecord',
	#superclass : 'Object',
	#traits : 'THiDePersistency',
	#classTraits : 'THiDePersistency classTrait',
	#instVars : [
		'query',
		'result',
		'thumbnail'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideLoad: aFileReference storage: aHiDeStorage [

	self
		loadQuery: aFileReference;
		loadResult: aFileReference;
		loadThumbnail: aFileReference
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideSave: aFileReference storage: aHiDeStorage [

	self
		saveQuery: aFileReference;
		saveResult: aFileReference;
		saveThumbnail: aFileReference
]

{ #category : 'hideho-operations' }
GolapQueryRecord >> hideUpdateMetadataStorage: aHiDeStorage [

	
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
GolapQueryRecord >> loadResult: aFileReference [

	aFileReference / 'result.csv' ifExists: [ :ref |
		ref readStreamDo: [ :stream |
			result := stream upToEnd.
			^ self ] ].
	result := nil
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
GolapQueryRecord >> saveQuery: aFileReference [

	query ifNotNil: [
		(aFileReference / 'query.json')
			ensureDelete;
			writeStreamDo: [ :stream |
				stream nextPutAll: (GolapQueryJSONReaderWriter toString: query) ] ]
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

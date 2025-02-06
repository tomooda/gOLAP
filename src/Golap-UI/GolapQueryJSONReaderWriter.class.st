Class {
	#name : 'GolapQueryJSONReaderWriter',
	#superclass : 'NeoJSONReader',
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'utilities' }
GolapQueryJSONReaderWriter class >> toString: anObject [

	| json |
	json := anObject.
	json isDictionary ifTrue: [
		| newJson |
		newJson := nil.
		json at: 'query' ifPresent: [ :query |
			query at: 'itemFilter' ifPresent: [ :itemFilter |
				itemFilter isDictionary ifTrue: [
					newJson ifNil: [
						json := newJson := json copy.
						newJson at: 'query' put: query copy ].
					(newJson at: 'query') at: 'itemfilter' put: (itemFilter size > 1
							 ifTrue: [ 'and(' , (', ' join: itemFilter values) , ')' ]
							 ifFalse: [ itemFilter asArray first ]) ] ].
			query at: 'traFilter' ifPresent: [ :traFilter |
				traFilter isDictionary ifTrue: [
					newJson ifNil: [
						json := newJson := json copy.
						newJson at: 'query' put: query copy ].
					(newJson at: 'query') at: 'traFilter' put: (traFilter size > 1
							 ifTrue: [ 'and(' , (', ' join: traFilter values) , ')' ]
							 ifFalse: [ traFilter asArray first ]) ] ] ] ].
	^ STONJSON toString: json
]

{ #category : 'utilities' }
GolapQueryJSONReaderWriter class >> toStringPretty: anObject [

	| json |
	json := anObject.
	json isDictionary ifTrue: [
		| newJson |
		newJson := nil.
		json at: 'query' ifPresent: [ :query |
			query at: 'itemFilter' ifPresent: [ :itemFilter |
				itemFilter isDictionary ifTrue: [
					newJson ifNil: [
						json := newJson := json copy.
						newJson at: 'query' put: query copy ].
					(newJson at: 'query') at: 'itemfilter' put: (itemFilter size > 1
							 ifTrue: [ 'and(' , (', ' join: itemFilter values) , ')' ]
							 ifFalse: [ itemFilter asArray first ]) ] ].
			query at: 'traFilter' ifPresent: [ :traFilter |
				traFilter isDictionary ifTrue: [
					newJson ifNil: [
						json := newJson := json copy.
						newJson at: 'query' put: query copy ].
					(newJson at: 'query') at: 'traFilter' put: (traFilter size > 1
							 ifTrue: [ 'and(' , (', ' join: traFilter values) , ')' ]
							 ifFalse: [ traFilter asArray first ]) ] ] ] ].
	^ STONJSON toStringPretty: json
]

{ #category : 'accessing' }
GolapQueryJSONReaderWriter >> mapClass [
	"Return the collection type to use for JSON maps"

	^ mapClass ifNil: [ HiDeSyntaxDictionary ]
]

{ #category : 'accessing' }
GolapQueryJSONReaderWriter >> next [

	^ super next ifNotNil: [ :json |
		  json isDictionary ifTrue: [
			  json at: 'query' ifPresent: [ :query |
				  query at: 'itemFilter' ifPresent: [ :itemFilter |
					  query
						  at: 'itemFilter'
						  put: (GolapFilterParser current parse: itemFilter) ].
				  query at: 'traFilter' ifPresent: [ :traFilter |
					  query
						  at: 'traFilter'
						  put: (GolapFilterParser current parse: traFilter) ] ] ].
		  json ]
]

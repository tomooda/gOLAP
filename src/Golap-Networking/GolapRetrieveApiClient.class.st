Class {
	#name : 'GolapRetrieveApiClient',
	#superclass : 'Object',
	#instVars : [
		'url',
		'authenticateBlock',
		'serverConfig',
		'idField',
		'attributeNames'
	],
	#category : 'Golap-Networking',
	#package : 'Golap-Networking'
}

{ #category : 'instance creation' }
GolapRetrieveApiClient class >> url: aZnUrl authenticateBlock: aBlock [

	^ self url: aZnUrl authenticateBlock: aBlock serverConfig: nil
]

{ #category : 'instance creation' }
GolapRetrieveApiClient class >> url: aZnUrl authenticateBlock: aBlock serverConfig: aDictionary [

	^ self new
		  url: aZnUrl;
		  authenticateBlock: aBlock;
		  serverConfig: aDictionary;
		  yourself
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> attributeNames [

	^ attributeNames ifNil: [
			  self serverConfig ifNotNil: [ :config |
					  config at: 'itemAttFile' ifPresent: [ :itemAttFile |
							  attributeNames := (itemAttFile
								                     at: 'strFields'
								                     ifPresent: [ :strFields | (strFields substrings: ',') collect: #trim thenSelect: #notEmpty ]
								                     ifAbsent: [ #(  ) ]) , (itemAttFile
								                     at: 'numFields'
								                     ifPresent: [ :strFields | (strFields substrings: ',') collect: #trim thenSelect: #notEmpty ]
								                     ifAbsent: [ #(  ) ]) ] ].
			  attributeNames ]
]

{ #category : 'api' }
GolapRetrieveApiClient >> attributesAndValuesAt: aString do: aBlock [

	self attributeNames do: [ :attr |
		self idField ~= attr ifTrue: [ self valuesAt: attr fromIds: { aString } do: [ :value | aBlock value: attr value: value ] ] ]
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> authenticateBlock [

	^ authenticateBlock
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> authenticateBlock: aBlock [

	authenticateBlock := aBlock
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> idField [

	^ idField ifNil: [
			  idField := self serverConfig ifNotNil: [ :config |
				             config at: 'traFile' ifPresent: [ :traFile | traFile at: 'itemFld' ifAbsent: [ nil ] ] ] ]
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> serverConfig [

	^ serverConfig ifNil: [
			  [
				  serverConfig := (GolapHttpClient
					                   post: self url
					                   data: (ZnEntity json: '{"control":"config"}')
					                   timeout: self timeout
					                   authenticateBlock: self authenticateBlock) in: [ :response |
						                  response code = 200 ifFalse: [ ^ nil ].
						                  response entity readStream in: [ :stream |
								                  | status |
								                  status := (stream upTo: Character lf) substrings: ':'.
								                  status size = 2 ifFalse: [ ^ nil ].
								                  status second trim = '0' ifFalse: [ ^ nil ].
								                  (NeoJSONReader on: stream)
									                  mapClass: OrderedDictionary;
									                  next ] ] ]
				  on: NetworkError , ZnParseError
				  do: [ :ex | ^ nil ] ]
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> serverConfig: aDictionary [

	serverConfig := aDictionary
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> timeout [

	^ 0
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> url [

	^ url
]

{ #category : 'accessing' }
GolapRetrieveApiClient >> url: aZnUrl [

	url := aZnUrl asZnUrl
]

{ #category : 'api' }
GolapRetrieveApiClient >> valuesAt: aString [

	^ Array streamContents: [ :stream | self valuesAt: aString do: [ :value | stream nextPut: value ] ]
]

{ #category : 'api' }
GolapRetrieveApiClient >> valuesAt: aString do: aBlock [

	^ self valuesAt: aString filters: #(  ) do: aBlock
]

{ #category : 'api' }
GolapRetrieveApiClient >> valuesAt: aString filters: aCollection do: aBlock [

	| predicates json |
	predicates := aCollection collect: [ :assoc |
			              String streamContents: [ :stream |
					              stream
						              nextPutAll: 'isin(';
						              nextPutAll: assoc key asString.
					              assoc value do: [ :value |
							              stream
								              nextPutAll: ',"';
								              nextPutAll: value asString;
								              nextPutAll: '"' ].
					              stream nextPut: $) ] ].
	json := OrderedDictionary new.
	json at: 'retrieve' put: 'GetItmAtt,' , aString.
	predicates ifNotEmpty: [
			json at: 'itemFilter' put: (predicates size >= 2
					 ifTrue: [ 'and(' , (',' join: predicates) , ')' ]
					 ifFalse: [ predicates first ]) ].
	[
		| response |
		response := GolapHttpClient new
			            url: url;
			            entity: (ZnEntity json: (STONJSON toString: json));
			            authenticateBlock: self authenticateBlock;
			            post;
			            response.
		response isSuccess ifTrue: [ response contents lines allButFirstDo: aBlock ] ]
		on: Exception
		do: [ :ex |  ]
]

{ #category : 'api' }
GolapRetrieveApiClient >> valuesAt: aString fromIds: aCollection do: aBlock [

	self valuesAt: aString filters: { (self idField -> (aCollection collect: #asString)) } do: aBlock
]

{ #category : 'api' }
GolapRetrieveApiClient >> valuesAt: aString fromNodes: aCollectionOfGolapNode do: aBlock [

	^ self valuesAt: aString fromIds: (aCollectionOfGolapNode collect: #id) do: aBlock
]

Class {
	#name : #GolapApiClient,
	#superclass : #Object,
	#instVars : [
		'url',
		'authenticateBlock',
		'query',
		'comment',
		'itemFieldQuerySpec',
		'serverConfig'
	],
	#classInstVars : [
		'random'
	],
	#category : #'Golap-Networking'
}

{ #category : #utilities }
GolapApiClient class >> random [
	^ random ifNil: [ random := Random new ]
]

{ #category : #'instance cretion' }
GolapApiClient class >> url: aStringOrUrl query: aString authenticateBlock: aBlock [

	^ self new
		  url: aStringOrUrl;
		  query: aString;
		  authenticateBlock: aBlock;
		  yourself
]

{ #category : #'instance cretion' }
GolapApiClient class >> url: aStringOrUrl query: aString comment: anotherString serverConfig: configDictionary itemFieldQuerySpec: aDictionary authenticateBlock: aBlock [

	^ self new
		  url: aStringOrUrl;
		  query: aString;
		  comment: anotherString;
		  serverConfig: configDictionary;
		  itemFieldQuerySpec: aDictionary;
		  authenticateBlock: aBlock;
		  yourself
]

{ #category : #accessing }
GolapApiClient >> authenticateBlock [
	^ authenticateBlock
]

{ #category : #accessing }
GolapApiClient >> authenticateBlock: aBlock [
	authenticateBlock := aBlock
]

{ #category : #private }
GolapApiClient >> cancel: aString [
	| response |
	response := GolapHttpClient
		get: self url / 'cancel' / aString
		authenticateBlock: self authenticateBlock.
	^ response entity contents
]

{ #category : #accessing }
GolapApiClient >> comment [

	^ comment
]

{ #category : #accessing }
GolapApiClient >> comment: aString [

	comment := aString
]

{ #category : #private }
GolapApiClient >> createRunId [

	<script: 'GolapApiClient new createRunId inspect'>
	^ String streamContents: [ :stream | 
		  16 timesRepeat: [ (self random nextInteger: 9) printOn: stream ] ]
]

{ #category : #accessing }
GolapApiClient >> imageUrl [
	^ self serverConfig at: 'imageUrl' ifAbsent: [ nil ]
]

{ #category : #accessing }
GolapApiClient >> itemFieldQuerySpec [

	^ itemFieldQuerySpec ifNil: [ 
		  itemFieldQuerySpec := serverConfig
			                        ifNotNil: [ :config | 
			                        config
				                        at: 'statsFunc'
				                        ifAbsent: [ Dictionary new ] ]
			                        ifNil: [ Dictionary new ] ]
]

{ #category : #accessing }
GolapApiClient >> itemFieldQuerySpec: aDictionary [
	itemFieldQuerySpec := aDictionary
]

{ #category : #private }
GolapApiClient >> jobProgressBar [
	^ (World findDeeplyA: JobProgressBarMorph) findA: ImageMorph
]

{ #category : #accessing }
GolapApiClient >> query [
	^ query
]

{ #category : #accessing }
GolapApiClient >> query: aString [
	query := aString withUnixLineEndings
]

{ #category : #private }
GolapApiClient >> random [
	^ self class random
]

{ #category : #accessing }
GolapApiClient >> readStream [

	"GolapApiClient new entity"

	[ 
	| response |
	UIManager default
		displayProgress: 'posting a request to ' , self url asString
		from: 0.0
		to: 1.0
		during: [ :bar | 
			| runId queryJSON client |
			runId := self createRunId.
			queryJSON := STONJSON fromString: self query.
			(queryJSON at: 'query' ifAbsentPut: [ Dictionary new ])
				at: 'runID'
				put: runId.
			query := STONJSON toString: queryJSON.
			self jobProgressBar
				clearEvent: #mouseUp;
				on: #mouseUp send: #value to: [ self cancel: runId ].
			client := GolapHttpClient new
				          timeout: (([ NeoJSONReader fromString: self query ]
						            on: Error
						            do: [ :ex | ex return: Dictionary new ])
						           at: 'deadlineTimer'
						           ifAbsent: [ 600 ]) + 5;
				          url: self url;
				          authenticateBlock: self authenticateBlock;
				          yourself.
			bar value: 0.1.
			client entity: (ZnStringEntity text: self query).
			bar value: 0.2.
			client post.
			bar value: 0.5.
			response := client response.
			bar value: 1.0.
			response isSuccess ifFalse: [ ^ response statusLine asString ].
			^ response entity readStream ] ]
		on:
			NetworkError , ZnParseError , ZnHttpUnsuccessful , ZnMissingHost
			, ZnTooManyRedirects , ZnUnexpectedContentType
		do: [ :ex | 
			^ (ex messageText ifEmpty: [ 'Network error' ]) , ': '
			  , url asString ]
]

{ #category : #accessing }
GolapApiClient >> serverConfig [

	^ serverConfig ifNil: [ 
		  [ 
		  serverConfig := (GolapHttpClient
			                   post: self url
			                   data: (ZnEntity json: '{"control":"config"}')
			                   timeout: self timeout
			                   authenticateBlock: self authenticateBlock) in: [ 
			                  :response | 
			                  response code = 200 ifFalse: [ ^ nil ].
			                  response entity readStream in: [ :stream | 
				                  | status |
				                  status := (stream upTo: Character lf) 
					                            substrings: ':'.
				                  status size = 2 ifFalse: [ ^ nil ].
				                  status second trim = '0' ifFalse: [ ^ nil ].
				                  (NeoJSONReader on: stream)
					                  mapClass: OrderedDictionary;
					                  next ] ] ]
			  on: NetworkError , ZnParseError
			  do: [ :ex | ^ nil ] ]
]

{ #category : #accessing }
GolapApiClient >> serverConfig: aDictionary [
	serverConfig := aDictionary
]

{ #category : #accessing }
GolapApiClient >> timeout [
	^ 3
]

{ #category : #accessing }
GolapApiClient >> url [
	^ url
]

{ #category : #accessing }
GolapApiClient >> url: aStringOrZnUrl [
	url := aStringOrZnUrl asUrl
]

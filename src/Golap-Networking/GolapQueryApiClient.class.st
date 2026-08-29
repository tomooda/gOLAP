Class {
	#name : 'GolapQueryApiClient',
	#superclass : 'Object',
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
	#category : 'Golap-Networking',
	#package : 'Golap-Networking'
}

{ #category : 'utilities' }
GolapQueryApiClient class >> random [
	^ random ifNil: [ random := Random new ]
]

{ #category : 'instance cretion' }
GolapQueryApiClient class >> url: aStringOrUrl query: aString authenticateBlock: aBlock [

	^ self new
		  url: aStringOrUrl;
		  query: aString;
		  authenticateBlock: aBlock;
		  yourself
]

{ #category : 'instance cretion' }
GolapQueryApiClient class >> url: aStringOrUrl query: aString comment: anotherString serverConfig: configDictionary itemFieldQuerySpec: aDictionary authenticateBlock: aBlock [

	^ self new
		  url: aStringOrUrl;
		  query: aString;
		  comment: anotherString;
		  serverConfig: configDictionary;
		  itemFieldQuerySpec: aDictionary;
		  authenticateBlock: aBlock;
		  yourself
]

{ #category : 'accessing' }
GolapQueryApiClient >> authenticateBlock [
	^ authenticateBlock
]

{ #category : 'accessing' }
GolapQueryApiClient >> authenticateBlock: aBlock [
	authenticateBlock := aBlock
]

{ #category : 'private' }
GolapQueryApiClient >> cancel: aString [
	| response |
	response := GolapHttpClient
		get: self url / 'cancel' / aString
		authenticateBlock: self authenticateBlock.
	^ response entity contents
]

{ #category : 'accessing' }
GolapQueryApiClient >> comment [

	^ comment
]

{ #category : 'accessing' }
GolapQueryApiClient >> comment: aString [

	comment := aString
]

{ #category : 'private' }
GolapQueryApiClient >> createRunId [

	<script: 'GolapApiClient new createRunId inspect'>
	^ String streamContents: [ :stream | 
		  16 timesRepeat: [ (self random nextInteger: 9) printOn: stream ] ]
]

{ #category : 'accessing' }
GolapQueryApiClient >> imageUrl [
	^ self serverConfig at: 'imageUrl' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GolapQueryApiClient >> itemFieldQuerySpec [

	^ itemFieldQuerySpec ifNil: [
			  itemFieldQuerySpec := serverConfig ifNotNil: [ :config |
					                        | querySpec |
					                        querySpec := Dictionary new.
					                        config
						                        at: 'statsFunc'
						                        ifPresent: [ :statsFunc | statsFunc keysAndValuesDo: [ :key :value | querySpec at: key put: value ] ].
					                        querySpec ] ]
]

{ #category : 'accessing' }
GolapQueryApiClient >> itemFieldQuerySpec: aDictionary [
	itemFieldQuerySpec := aDictionary
]

{ #category : 'private' }
GolapQueryApiClient >> jobProgressBar [
	^ (World findDeeplyA: JobProgressBarMorph) findA: ImageMorph
]

{ #category : 'accessing' }
GolapQueryApiClient >> query [
	^ query
]

{ #category : 'accessing' }
GolapQueryApiClient >> query: aString [
	query := aString withUnixLineEndings
]

{ #category : 'private' }
GolapQueryApiClient >> random [
	^ self class random
]

{ #category : 'accessing' }
GolapQueryApiClient >> readStream [
	"GolapApiClient new entity"

	[
		| response |
		UIManager default
			displayProgress: 'サーバにクエリを送信中' , self url asString
			from: 0.0
			to: 1.0
			during: [ :bar |
					| runId queryJSON client |
					runId := self createRunId.
					queryJSON := GolapJSON fromString: self query.
					(queryJSON at: 'query' ifAbsentPut: [ Dictionary new ])
						at: 'runID'
						put: runId.
					query := GolapJSON toString: queryJSON.
					self jobProgressBar
						clearEvent: #mouseUp;
						on: #mouseUp send: #value to: [ self cancel: runId ].
					client := GolapHttpClient new
						          timeout: (([ GolapJSON fromString: self query ]
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
			^ (ex messageText ifEmpty: [ '送信失敗' ]) , ': '
			  , url asString ]
]

{ #category : 'accessing' }
GolapQueryApiClient >> serverConfig [

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

{ #category : 'accessing' }
GolapQueryApiClient >> serverConfig: aDictionary [
	serverConfig := aDictionary
]

{ #category : 'accessing' }
GolapQueryApiClient >> timeout [
	^ 0
]

{ #category : 'accessing' }
GolapQueryApiClient >> url [
	^ url
]

{ #category : 'accessing' }
GolapQueryApiClient >> url: aStringOrZnUrl [

	url := aStringOrZnUrl asZnUrl
]

Class {
	#name : #GolapHttpClient,
	#superclass : #ZnClient,
	#instVars : [
		'authenticateBlock'
	],
	#category : #'Golap-Networking'
}

{ #category : #public }
GolapHttpClient class >> client [
	^ self new
]

{ #category : #public }
GolapHttpClient class >> clientWithAuthenticateBlock: aBlock [
	^ self new
		authenticateBlock: aBlock;
		yourself
]

{ #category : #public }
GolapHttpClient class >> get: aZnUrl [
	^ self client
		beOneShot;
		url: aZnUrl;
		get;
		response
]

{ #category : #public }
GolapHttpClient class >> get: aZnUrl authenticateBlock: aBlock [
	^ self client
		beOneShot;
		authenticateBlock: aBlock;
		url: aZnUrl;
		get;
		response
]

{ #category : #public }
GolapHttpClient class >> post: aZnUrl [
	^ self client
		beOneShot;
		url: aZnUrl;
		post;
		response
]

{ #category : #public }
GolapHttpClient class >> post: aZnUrl authenticateBlock: aBlock [
	^ self client
		beOneShot;
		authenticateBlock: aBlock;
		url: aZnUrl;
		post;
		response
]

{ #category : #public }
GolapHttpClient class >> post: aZnUrl data: aZnEntity [
	^ self client
		beOneShot;
		url: aZnUrl;
		entity: aZnEntity;
		post;
		response
]

{ #category : #public }
GolapHttpClient class >> post: aZnUrl data: aZnEntity authenticateBlock: aBlock [
	^ self client
		beOneShot;
		url: aZnUrl;
		authenticateBlock: aBlock;
		entity: aZnEntity;
		post;
		response
]

{ #category : #public }
GolapHttpClient class >> post: urlObject data: entity timeout: seconds [
	^ self client
		url: urlObject;
		entity: entity;
		timeout: seconds;
		post;
		response
]

{ #category : #public }
GolapHttpClient class >> post: urlObject data: entity timeout: seconds authenticateBlock: aBlock [
	^ self client
		url: urlObject;
		entity: entity;
		timeout: seconds;
		authenticateBlock: aBlock;
		post;
		response
]

{ #category : #private }
GolapHttpClient >> a1ForUserName: username password: password realm: realm [
	^ self
		md5Hash:
			(String
				streamContents: [ :stream | 
					stream
						nextPutAll: username;
						nextPut: $:;
						nextPutAll: realm;
						nextPut: $:;
						nextPutAll: password ])
]

{ #category : #private }
GolapHttpClient >> a2ForUrl: url method: method [
	^ self
		md5Hash:
			(String
				streamContents: [ :stream | 
					stream
						nextPutAll: method asString;
						nextPut: $:;
						nextPutAll: url asString ])
]

{ #category : #private }
GolapHttpClient >> authenticate [
	self authenticateBlock
		value: [ :username :password | 
			| params result |
			params := self getAuthParams ifNil: [ ^ nil ].
			request headers
				at: 'Authorization'
				put:
					(self
						authorizationForUsername: username
						password: password
						params: params).
			response := nil.
			self prepareRequest.
			self withProgressDo: [ result := self executeWithTimeout ].
			self prepareNextRequest.
			^ result ].
	^ nil
]

{ #category : #accessing }
GolapHttpClient >> authenticateBlock [
	^ authenticateBlock
		ifNil: [ authenticateBlock := [ :auth | 
			(UIManager default request: 'username')
				ifNotNil: [ :username | 
					(UIManager default requestPassword: 'password')
						ifNotNil: [ :password | auth value: username value: password ] ] ] ]
]

{ #category : #accessing }
GolapHttpClient >> authenticateBlock: aBlock [
	authenticateBlock := aBlock
]

{ #category : #private }
GolapHttpClient >> authorizationForUsername: username password: password params: params [
	| realm nonce opaque a1 a2 |
	realm := params at: 'realm' ifAbsent: [ ^ nil ].
	nonce := params at: 'nonce' ifAbsent: [ ^ nil ].
	opaque := params at: 'opaque' ifAbsent: [ ^ nil ].
	a1 := self a1ForUserName: username password: password realm: realm.
	a2 := self a2ForUrl: request url method: request method.
	^ String
		streamContents: [ :stream | 
			stream
				nextPutAll: 'Digest username="';
				nextPutAll: username;
				nextPutAll: '",realm="';
				nextPutAll: realm;
				nextPutAll: '",nonce="';
				nextPutAll: nonce;
				nextPutAll: '",uri="';
				nextPutAll: request url asString;
				nextPutAll: '",opaque="';
				nextPutAll: opaque;
				nextPutAll: '",response="';
				nextPutAll: (self md5Hash: a1 , ':' , nonce , ':' , a2);
				nextPut: $" ]
]

{ #category : #private }
GolapHttpClient >> createCnonce [
	^ String streamContents:  [ :stream | 32 timesRepeat: [ stream nextPut: '0123456789abcdef' atRandom ] ]
]

{ #category : #operations }
GolapHttpClient >> execute [
	| result |
	result := super execute.
	response code = 401
		ifTrue: [ self authenticate ifNotNil: [ :r | result := r ] ].
	^ result
]

{ #category : #private }
GolapHttpClient >> getAuthParams [
	| header |
	header := response headers at: 'Www-Authenticate' ifAbsent: [ ^ nil ].
	(header first: 7) = 'Digest '
		ifFalse: [ ^ nil ].
	^ (((header copyFrom: 8 to: header size) substrings: ',')
		collect: [ :def | 
			| index |
			index := def indexOf: $=.
			index = 0
				ifTrue: [ ^ nil ].
			(def copyFrom: 1 to: index - 1)
				-> (def copyFrom: index + 2 to: def size - 1) ]) asDictionary
]

{ #category : #initialization }
GolapHttpClient >> initialize [

	super initialize.
	self maximumEntitySize: 256 * 1024 * 1024
]

{ #category : #private }
GolapHttpClient >> md5Hash: aString [
	^ (MD5 new
		initialize;
		hashStream: aString asByteArray readStream) hex
]

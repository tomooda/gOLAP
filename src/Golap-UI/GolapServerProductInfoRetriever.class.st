Class {
	#name : 'GolapServerProductInfoRetriever',
	#superclass : 'GolapItemInfoRetriever',
	#instVars : [
		'cachedImages',
		'cachedItemInfos',
		'query',
		'authenticateBlock',
		'imageRepositoryUrl',
		'golapServerUrl',
		'itemFieldQuerySpec',
		'serverConfig'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapServerProductInfoRetriever class >> fromApiClient: aGolapApiClient [

	^ self new
		  setApiClient: aGolapApiClient;
		  yourself
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever class >> tag [

	^ 'server'
]

{ #category : 'converting' }
GolapServerProductInfoRetriever >> asJSON [

	^ OrderedDictionary new
		  at: self class tag put: {
				  ('server-url' -> golapServerUrl asString).
				  ('server-config' -> serverConfig).
				  ('image-url' -> imageRepositoryUrl asString).
				  ('item-query' -> itemFieldQuerySpec).
				  ('query' -> query) } asOrderedDictionary;
		  yourself
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> authenticateBlock [
	^ authenticateBlock
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> authenticateBlock: aBlock [
	authenticateBlock := aBlock
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> golapServerUrl [

	^ golapServerUrl
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> golapServerUrl: aString [

	golapServerUrl := aString asUrl
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> imageRepositoryUrl [

	^ imageRepositoryUrl
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> imageRepositoryUrl: aString [

	imageRepositoryUrl := aString ifNotNil: #asUrl
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> imageRequestJsonFor: aString [
	^ '{"nodeimage": {"itemVal": "' , aString asString , '"},"deadlineTimer":0}'
]

{ #category : 'initialization' }
GolapServerProductInfoRetriever >> initialize [
	super initialize.
	cachedImages := Dictionary new.
	cachedItemInfos := Dictionary new.

]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> itemFieldQuerySpec [

	^ itemFieldQuerySpec
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> itemFieldQuerySpec: aDictionary [

	itemFieldQuerySpec := aDictionary
]

{ #category : 'http' }
GolapServerProductInfoRetriever >> itemInfoRequestJsonFor: aString [
	| q fields |
	fields := itemFieldQuerySpec associations
		collect: [ :assoc | assoc key , ':' , assoc value ].
	q := {('nodestat'
		->
			{('itemVal' -> aString).
			('values' -> (',' join: fields))} asDictionary).
	('deadlineTimer' -> 0)} asDictionary.
	self query
		ifNotNil: [ self query
				at: 'query'
				ifPresent: [ :q2 | 
					q2
						at: 'traFilter'
						ifPresent: [ :traFilter | (q at: 'nodestat') at: 'traFilter' put: traFilter ].
					q2
						at: 'itemFilter'
						ifPresent: [ :itemFilter | (q at: 'nodestat') at: 'itemFilter' put: itemFilter ].
					q2
						at: 'granularity'
						ifPresent:
							[ :granularity | (q at: 'nodestat') at: 'granularity' put: granularity ] ] ].
	^ NeoJSONWriter toString: q
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> productDataFor: aGolapNode [

	^ cachedItemInfos
		  at: aGolapNode id
		  ifAbsentPut: [ self retrieveItemInfoFor: aGolapNode id ]
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> query [

	^ query
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> query: aDictionary [

	query := aDictionary
]

{ #category : 'http' }
GolapServerProductInfoRetriever >> retrieveImagesFor: aString [

	| filenames |
	(golapServerUrl isNil or: [ imageRepositoryUrl isNil ]) ifTrue: [
		^ nil ].
	aString ifNil: [ ^ Array new ].
	[
	filenames := (GolapHttpClient
		              post: golapServerUrl
		              data:
		              (ZnEntity json: (self imageRequestJsonFor: aString))
		              authenticateBlock: self authenticateBlock) entity
		             contents trim lines ]
		on: Error
		do: [ :ex | ^ nil ].
	3 timesRepeat: [
		3 to: filenames size do: [ :index |
			| filename |
			filename := filenames at: index.
			[
			| response |
			response := GolapHttpClient get: imageRepositoryUrl / filename.
			response isSuccess ifTrue: [
				^ ImageReadWriter formFromStream: response entity readStream ] ]
				on: Exception
				do: [ :ex |  ].
			500 milliSecond wait ] ].
	^ nil
]

{ #category : 'http' }
GolapServerProductInfoRetriever >> retrieveItemInfoFor: aString [

	| itemInfo response stream header reader |
	itemInfo := OrderedCollection new.
	(golapServerUrl isNil or: [ aString isNil ]) ifTrue: [ ^ itemInfo ].
	[
	response := GolapHttpClient
		            post: golapServerUrl
		            data:
		            (ZnEntity json: (self itemInfoRequestJsonFor: aString))
		            authenticateBlock: self authenticateBlock ]
		on: Error
		do: [ :ex | ^ itemInfo ].
	response isSuccess ifFalse: [ ^ itemInfo ].
	stream := response entity contents readStream.
	header := (stream upTo: Character lf) trim.
	reader := NeoCSVReader on: stream.
	reader next
		with: reader next
		do: [ :key :value | itemInfo add: key -> value ].
	^ itemInfo
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> serverConfig [

	^ serverConfig
]

{ #category : 'accessing' }
GolapServerProductInfoRetriever >> serverConfig: aDictionary [

	serverConfig := aDictionary
]

{ #category : 'private' }
GolapServerProductInfoRetriever >> setApiClient: aGolapApiClient [

	self authenticateBlock: aGolapApiClient authenticateBlock.
	self golapServerUrl: aGolapApiClient url.
	self imageRepositoryUrl: aGolapApiClient imageUrl.
	self itemFieldQuerySpec: aGolapApiClient itemFieldQuerySpec.
	self query: (NeoJSONReader fromString: aGolapApiClient query).
	self serverConfig: aGolapApiClient serverConfig
]

{ #category : 'private' }
GolapServerProductInfoRetriever >> setFromJSON: aDictionary [

	aDictionary at: self class tag ifPresent: [ :json |
		json at: 'server-url' ifPresent: [ :url | self golapServerUrl: url ].
		json
			at: 'image-url'
			ifPresent: [ :url | self imageRepositoryUrl: url ].
		json at: 'item-query' ifPresent: [ :q | self itemFieldQuerySpec: q ].
		json at: 'server-config' ifPresent: [ :s | self serverConfig: s ].
		json at: 'query' ifPresent: [ :q | self query: q ] ]
]

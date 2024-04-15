Class {
	#name : #GolapItemView,
	#superclass : #SpPresenter,
	#instVars : [
		'item',
		'cachedImages',
		'imageIndex',
		'infoList',
		'itemImage',
		'nextImageButton',
		'prevImageButton',
		'serverUrlField',
		'imageRepositoryField',
		'cachedItemInfos',
		'query',
		'itemName',
		'itemFieldQuerySpec',
		'authenticateBlock',
		'golap',
		'vertex'
	],
	#classVars : [
		'EmptyImage',
		'ImageRepositoryUrl'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #layout }
GolapItemView class >> defaultLayout [
	<spec>
	^ SpBoxLayout newVertical
		add: #serverUrlField height: self buttonHeight;
		add: #infoList;
		add: #imageRepositoryField height: self buttonHeight;
		add: #itemImage;
		add:
			(SpBoxLayout newHorizontal
				add: #prevImageButton;
				add: #nextImageButton)
			height: self buttonHeight
]

{ #category : #'instance creation' }
GolapItemView class >> on: aGolap [

	^ self new
		  golap: aGolap;
		  yourself
]

{ #category : #accessing }
GolapItemView >> authenticateBlock [
	^ authenticateBlock
]

{ #category : #accessing }
GolapItemView >> authenticateBlock: aBlock [
	authenticateBlock := aBlock
]

{ #category : #accessing }
GolapItemView >> basicImage [

	^ self images ifNotNil: [ :images | 
		  images at: imageIndex value ifAbsent: [ nil ] ]
]

{ #category : #private }
GolapItemView >> emptyImage [
	^ EmptyImage
		ifNil: [ | image |
			image := Form extent: 16 @ 16 depth: 32.
			image getCanvas fillColor: Color white.
			image ]
]

{ #category : #accessing }
GolapItemView >> golap: aGolap [
	golap := aGolap
]

{ #category : #accessing }
GolapItemView >> image [

	^ self basicImage ifNil: [ self emptyImage ]
]

{ #category : #accessing }
GolapItemView >> imageRepositoryUrl: aString [

	imageRepositoryField text: (aString ifNil: [ '' ])
]

{ #category : #http }
GolapItemView >> imageRequestJsonFor: aString [
	^ '{"nodeimage": {"itemVal": "' , aString asString , '"},"deadlineTimer":0}'
]

{ #category : #private }
GolapItemView >> images [
	^ cachedImages
		at: item value
		ifAbsentPut: [ self retrieveImagesFor: item value ]
]

{ #category : #initialization }
GolapItemView >> initialize [
	super initialize.
	cachedImages := Dictionary new.
	cachedItemInfos := Dictionary new.
	item := nil asValueHolder
		whenChangedDo: [ self updateImage ];
		yourself.
	imageIndex := 1 asValueHolder
		whenChangedDo: [ self updateImage ];
		yourself.
	itemFieldQuerySpec := Dictionary new
]

{ #category : #initialization }
GolapItemView >> initializePresenters [
	serverUrlField := self newTextInput
		placeholder: 'Server URL';
		text: String new;
		whenSubmitDo: [ :text | 
			self
				updateImage;
				updateItemInfo ];
		yourself.
	imageRepositoryField := self newTextInput
		placeholder: 'URL for image repository';
		text: (ImageRepositoryUrl ifNil: [ String new ]);
		whenSubmitDo: [ :text | self updateImage ];
		yourself.
	infoList := self newTable
		enabled: false;
		addColumn: (SpStringTableColumn new evaluated: [ :assoc | assoc key asString ]);
		addColumn: (SpStringTableColumn new evaluated: [ :assoc | assoc value asString ]);
		yourself.
	itemImage := self newImage
		switchAutoscale;
		yourself.
	nextImageButton := self newButton
		label: 'next';
		action: [ imageIndex
				value:
					(imageIndex value + 1
						min: (self images ifNil: [ 0 ] ifNotNil: [ self images size ])
						max: 1) ];
		yourself.
	prevImageButton := self newButton
		label: 'prev';
		action: [ imageIndex value: (imageIndex value - 1 max: 1) ];
		yourself
]

{ #category : #accessing }
GolapItemView >> itemFieldQuerySpec [
	^ itemFieldQuerySpec
]

{ #category : #accessing }
GolapItemView >> itemFieldQuerySpec: aDictionary [
	itemFieldQuerySpec := aDictionary
]

{ #category : #accessing }
GolapItemView >> itemInfo [
	^ cachedItemInfos
		at: item
		ifAbsentPut: [ self retrieveItemInfoFor: item ]
]

{ #category : #http }
GolapItemView >> itemInfoRequestJsonFor: aString [
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

{ #category : #accessing }
GolapItemView >> query [
	^ query
]

{ #category : #accessing }
GolapItemView >> query: aDictionary [
	query := aDictionary
]

{ #category : #snapshot }
GolapItemView >> restore: aStream [

	(NeoJSONReader on: aStream) next ifNotNil: [ :json | 
		json
			at: 'server-url'
			ifPresent: [ :string | serverUrlField text: string ];
			at: 'image-url'
			ifPresent: [ :string | imageRepositoryField text: string ];
			at: 'item' ifPresent: [ :string | item value: string ];
			at: 'image-index' ifPresent: [ :int | imageIndex value: int ];
			at: 'query' ifPresent: [ :dict | query := dict ];
			at: 'item-query' ifPresent: [ :dict | itemFieldQuerySpec := dict ] ]
]

{ #category : #http }
GolapItemView >> retrieveImagesFor: aString [
	| imageRepo filenames |
	aString ifNil: [ ^ Array new ].
	imageRepo := imageRepositoryField text asString trim asUrl.
	[ filenames := (GolapHttpClient
		post: serverUrlField text asString trim asUrl
		data: (ZnEntity json: (self imageRequestJsonFor: aString))
		authenticateBlock: self authenticateBlock) entity contents trim
		lines.
	filenames size < 3
		ifTrue: [ ^ Array new ].
	^ (filenames copyFrom: 3 to: filenames size)
		collect: [ :filename | 
			| response |
			response := GolapHttpClient get: imageRepo / filename.
			response isSuccess
				ifTrue: [ ImageReadWriter
						formFromStream: (GolapHttpClient get: imageRepo / filename) entity readStream ]
				ifFalse: [ nil ] ]
		thenSelect: #notNil ]
		on: Error
		do: [ :ex | ^ Array new ]
]

{ #category : #http }
GolapItemView >> retrieveItemInfoFor: aString [
	| itemInfo response stream header reader |
	itemInfo := OrderedCollection new.
	aString ifNil: [ ^ itemInfo ].
	[ response := GolapHttpClient
		post: serverUrlField text asString trim asUrl
		data: (ZnEntity json: (self itemInfoRequestJsonFor: aString))
		authenticateBlock: self authenticateBlock ]
		on: Error
		do: [ :ex | ^ itemInfo ].
	response isSuccess
		ifFalse: [ ^ itemInfo ].
	stream := response entity contents readStream.
	header := (stream upTo: Character lf) trim.
	reader := NeoCSVReader on: stream.
	reader next
		with: reader next
		do: [ :key :value | itemInfo add: key -> value ].
	^ itemInfo
]

{ #category : #http }
GolapItemView >> retrieveSingleImageFor: aString [

	| imageRepo filenames |
	aString ifNil: [ ^ nil ].
	imageRepo := imageRepositoryField text asString trim asUrl.
	[ 
	filenames := (GolapHttpClient
		              post: serverUrlField text asString trim asUrl
		              data:
		              (ZnEntity json: (self imageRequestJsonFor: aString))
		              authenticateBlock: self authenticateBlock) entity
		             contents trim lines ]
		on: Error
		do: [ :ex | ^ nil ].
	filenames size < 3 ifTrue: [ ^ nil ].
	3 timesRepeat: [ 
		3 to: filenames size do: [ :index | 
			| filename |
			filename := filenames at: index.
			[ 
			| response |
			response := GolapHttpClient get: imageRepo / filename.
			response isSuccess ifTrue: [ 
				^ ImageReadWriter formFromStream: response entity readStream ] ]
				on: Error
				do: [ :ex |  ].
			500 milliSecond wait ] ].
	^ nil
]

{ #category : #accessing }
GolapItemView >> serverUrl: aString [

	serverUrlField text: aString
]

{ #category : #snapshot }
GolapItemView >> snapshot [

	golap snapshotItemView: [ :stream | self snapshotInto: stream ]
]

{ #category : #snapshot }
GolapItemView >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: { 
			('server-url' -> serverUrlField text asString).
			('image-url' -> imageRepositoryField text asString).
			('item' -> item value).
			('image-index' -> imageIndex value).
			('query' -> query).
			('item-query' -> itemFieldQuerySpec) } asOrderedDictionary
]

{ #category : #private }
GolapItemView >> updateImage [

	vertex ifNotNil: [
		self basicImage ifNotNil: [ :image |
			vertex photoimage: (image scaledToSize: 64 @ 64) ] ].
	^ itemImage image: self image
]

{ #category : #private }
GolapItemView >> updateItemInfo [
	^ infoList items: self itemInfo
]

{ #category : #accessing }
GolapItemView >> url [
	^ serverUrlField text asString asZnUrl
]

{ #category : #accessing }
GolapItemView >> vertex: aGolapVertex [

	vertex := aGolapVertex.
	item := aGolapVertex id.
	itemName := aGolapVertex name.
	imageIndex rawValue: 1.
	[
	self updateImage.
	self updateItemInfo ] forkAt: Processor userBackgroundPriority
]

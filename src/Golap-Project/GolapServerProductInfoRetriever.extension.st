Extension { #name : 'GolapServerProductInfoRetriever' }

{ #category : '*Golap-Project' }
GolapServerProductInfoRetriever >> asJSON [

	| json |
	json := super asJSON.
	golapServerUrl ifNotNil: [
		json at: 'server-url' put: golapServerUrl asString ].
	serverConfig ifNotNil: [ json at: 'server-config' put: serverConfig ].
	imageRepositoryUrl ifNotNil: [
		json at: 'image-url' put: imageRepositoryUrl asString ].
	itemFieldQuerySpec ifNotNil: [
		json at: 'item-query' put: itemFieldQuerySpec ].
	query ifNotNil: [ json at: 'query' put: query ].
	^ json
]

{ #category : '*Golap-Project' }
GolapServerProductInfoRetriever >> fromJSON: aDictionary [

	aDictionary
		at: 'server-url'
		ifPresent: [ :url | self golapServerUrl: url ].
	aDictionary
		at: 'image-url'
		ifPresent: [ :url | self imageRepositoryUrl: url ].
	aDictionary
		at: 'item-query'
		ifPresent: [ :q | self itemFieldQuerySpec: q ].
	aDictionary
		at: 'server-config'
		ifPresent: [ :s | self serverConfig: s ].
	aDictionary at: 'query' ifPresent: [ :q | self query: q ].
	super fromJSON: aDictionary
]

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

	aDictionary at: self class tag ifPresent: [ :json |
			json
				at: 'server-url'
				ifPresent: [ :url | self golapServerUrl: url ].
			json
				at: 'image-url'
				ifPresent: [ :url | self imageRepositoryUrl: url ].
			json
				at: 'item-query'
				ifPresent: [ :q | self itemFieldQuerySpec: q ].
			json at: 'server-config' ifPresent: [ :s | self serverConfig: s ].
			json at: 'query' ifPresent: [ :q | self query: q ] ].
	super fromJSON: aDictionary
]

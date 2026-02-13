Extension { #name : 'GolapNetworkClientPresenter' }

{ #category : '*Golap-Project' }
GolapNetworkClientPresenter >> asJSON [

	^ self basicAsJSON
		  at: 'url' put: urlInput text asString;
		  at: 'comment' put: commentText text asString;
		  at: 'basic-query' put: queryPresenter asJSON;
		  at: 'queryNotebook-index' put: queryNotebook selectedPageIndex;
		  yourself
]

{ #category : '*Golap-Project' }
GolapNetworkClientPresenter >> fromJSON: aDictionary [

	aDictionary
		at: 'url' ifPresent: [ :string |
				urlInput text: string.
				self urlInputSubmitted ];
		at: 'comment' ifPresent: [ :string | commentText text: string ];
		at: 'basic-query'
		ifPresent: [ :json | queryPresenter fromJSON: json ];
		at: 'queryNotebook-index'
		ifPresent: [ :integer | queryNotebook selectPageIndex: integer ].
	self basicFromJSON: aDictionary
]

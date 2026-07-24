Class {
	#name : 'GolapGooglePhotoImageRetriever',
	#superclass : 'GolapPhotoImageRetriever',
	#instVars : [
		'cseid',
		'apikey',
		'numImages'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapGooglePhotoImageRetriever class >> for: aGolapItemInfoRetriever [

	^ self new
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever class >> tag [

	^ 'google'
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> accessInterval [

	^ 1 second
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> apikey [

	^ apikey
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> apikey: aString [

	apikey := aString
]

{ #category : 'private' }
GolapGooglePhotoImageRetriever >> commit: copy [

	cseid := copy cseid.
	apikey := copy apikey
]

{ #category : 'user interface' }
GolapGooglePhotoImageRetriever >> configPresenter [

	^ GolapGooglePhotoImageRetrieverPresenter on: self
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> cseid [

	^ cseid
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> cseid: aString [

	cseid := aString
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> ensureApikey [

	^ apikey ifNil: [ apikey := self requestApikey ]
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> ensureCseid [

	^ cseid ifNil: [ cseid := self requestCseid ]
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> googleUrl [

	^ 'https://customsearch.googleapis.com/customsearch/v1' asZnUrl
]

{ #category : 'testing' }
GolapGooglePhotoImageRetriever >> hasConfigPresenter [

	^ true
]

{ #category : 'initialization' }
GolapGooglePhotoImageRetriever >> initialize [

	super initialize.
	cseid := self readCseid.
	apikey := self readApikey.
	numImages := 1
]

{ #category : 'testing' }
GolapGooglePhotoImageRetriever >> isAvailable [

	^ cseid notNil and: [ apikey notNil and: [ self enabled ] ]
]

{ #category : 'enumerating' }
GolapGooglePhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	aBlock value: aGolapNode name
]

{ #category : 'testing' }
GolapGooglePhotoImageRetriever >> needsCache [

	^ true
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> order [

	^ 100
]

{ #category : 'defaults' }
GolapGooglePhotoImageRetriever >> readApikey [

	| ref |
	ref := self golapDirectory / 'api-key'.
	^ ref isFile
		  ifTrue: [ ref contents ]
		  ifFalse: [ nil ]
]

{ #category : 'defaults' }
GolapGooglePhotoImageRetriever >> readCseid [

	| ref |
	ref := self golapDirectory / 'cse-id'.
	^ ref isFile
		  ifTrue: [ ref contents ]
		  ifFalse: [ nil ]
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> retrieveImageNamed: aString [

	self isAvailable ifFalse: [ ^ nil ].
	[
		| url |
		url := self googleUrl.
		url
			queryAt: 'cx' put: self cseid;
			queryAt: 'key' put: self apikey;
			queryAt: 'searchType' put: 'image';
			queryAt: 'num' put: numImages;
			queryAt: 'q' put: (aString copyReplaceAll: '_' with: '-').
		(GolapJSON fromString: url retrieveContents)
			at: 'items'
			ifPresent: [ :items |
					items do: [ :item |
							item at: 'image' ifPresent: [ :image |
									image at: 'thumbnailLink' ifPresent: [ :link |
											[
												^ ImageReadWriter formFromStream:
													  link asZnUrl retrieveBinaryContents readStream ]
												on: Exception
												do: [ :ex |  ] ] ] ] ] ]
		on: Error
		do: [ :ex |  ].
	^ nil
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetriever >> shortDescription [

	^ 'Google検索' , (self isAvailable
		   ifTrue: [ '' ]
		   ifFalse: [ ' (未設定)' ])
]

Class {
	#name : 'GolapGoogleApiClient',
	#superclass : 'Object',
	#instVars : [
		'cseid',
		'apikey',
		'params'
	],
	#category : 'Golap-Networking',
	#package : 'Golap-Networking'
}

{ #category : 'instance creation' }
GolapGoogleApiClient class >> cseid: aString apikey: anotherString [

	^ self new
		  cseid: aString;
		  apikey: anotherString;
		  yourself
]

{ #category : 'instance creation' }
GolapGoogleApiClient class >> searchThumbnail: aString [

	^ self new searchThumbnail: aString
]

{ #category : 'accessing' }
GolapGoogleApiClient >> apikey [

	^ apikey
]

{ #category : 'accessing' }
GolapGoogleApiClient >> apikey: aString [

	apikey := aString
]

{ #category : 'accessing' }
GolapGoogleApiClient >> at: queryKey put: aString [

	^ params at: queryKey put: aString asString
]

{ #category : 'accessing' }
GolapGoogleApiClient >> cseid [

	^ cseid
]

{ #category : 'accessing' }
GolapGoogleApiClient >> cseid: aString [

	cseid := aString
]

{ #category : 'accessing' }
GolapGoogleApiClient >> ensureApikey [

	^ apikey ifNil: [ apikey := self requestApikey ]
]

{ #category : 'accessing' }
GolapGoogleApiClient >> ensureCseid [

	^ cseid ifNil: [ cseid := self requestCseid ]
]

{ #category : 'accessing' }
GolapGoogleApiClient >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'accessing' }
GolapGoogleApiClient >> googleUrl [

	^ 'https://customsearch.googleapis.com/customsearch/v1' asZnUrl
]

{ #category : 'accessing' }
GolapGoogleApiClient >> initialize [

	super initialize.
	params := Dictionary new
		          at: 'searchType' put: 'image';
		          at: 'num' put: 1;
		          yourself
]

{ #category : 'testing' }
GolapGoogleApiClient >> isAvailable [

	^ cseid notNil and: [ apikey notNil ]
]

{ #category : 'accessing' }
GolapGoogleApiClient >> paramAt: queryKey ifAbsent: errorBlock [

	^ params at: queryKey ifAbsent: errorBlock
]

{ #category : 'accessing' }
GolapGoogleApiClient >> paramAt: queryKey ifPresent: aBlock [

	^ params at: queryKey ifPresent: aBlock
]

{ #category : 'accessing' }
GolapGoogleApiClient >> requestApikey [

	| ref |
	ref := self golapDirectory / 'api-key'.
	ref isFile ifFalse: [
		(UIManager default request:
			 'Google API keyを入力してください。ない場合は https://developers.google.com/custom-search/v1/introduction を参照')
			ifNotNil: [ :answer |
				ref writeStreamDo: [ :stream | stream nextPutAll: answer ] ]
			ifNil: [ ^ '' ] ].
	^ ref contents
]

{ #category : 'accessing' }
GolapGoogleApiClient >> requestCseid [

	| ref |
	ref := self golapDirectory / 'cse-id'.
	ref isFile ifFalse: [
		(UIManager default request:
			 '検索エンジンIDを入力してください。ない場合は https://developers.google.com/custom-search/v1/introduction を参照')
			ifNotNil: [ :answer |
				ref writeStreamDo: [ :stream | stream nextPutAll: answer ] ]
			ifNil: [ ^ '' ] ].
	^ ref contents
]

{ #category : 'accessing' }
GolapGoogleApiClient >> searchThumbnail: aString [

	self isAvailable ifTrue: [
		[
		| url |
		url := self googleUrl.
		url
			queryAt: 'cx' put: self cseid;
			queryAt: 'key' put: self apikey;
			queryAt: 'q' put: aString.
		params keysAndValuesDo: [ :key :value | url queryAt: key put: value ].
		(STONJSON fromString: url retrieveContents)
			at: 'items'
			ifPresent: [ :items |
				items first at: 'image' ifPresent: [ :image |
					image at: 'thumbnailLink' ifPresent: [ :thumbUrl |
						^ ImageReadWriter formFromStream:
							  thumbUrl asZnUrl retrieveBinaryContents readStream ] ] ] ]
			on: Exception
			do: [ :ex |  ] ].
	^ nil
]

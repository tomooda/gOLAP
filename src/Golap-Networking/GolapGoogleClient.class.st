Class {
	#name : 'GolapGoogleClient',
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
GolapGoogleClient class >> cseid: aString apikey: anotherString [

	^ self new
		  cseid: aString;
		  apikey: anotherString;
		  yourself
]

{ #category : 'utilities' }
GolapGoogleClient class >> searchThumbnail: aString [

	^ self new searchThumbnail: aString
]

{ #category : 'accessing' }
GolapGoogleClient >> apikey [

	^ apikey ifNil: [ apikey := self defaultApikey ]
]

{ #category : 'accessing' }
GolapGoogleClient >> apikey: anObject [

	apikey := anObject
]

{ #category : 'accessing' }
GolapGoogleClient >> at: queryKey put: aString [

	^ params at: queryKey put: aString asString
]

{ #category : 'accessing' }
GolapGoogleClient >> cseid [

	^ cseid ifNil: [ cseid := self defaultCseid ]
]

{ #category : 'accessing' }
GolapGoogleClient >> cseid: anObject [

	cseid := anObject
]

{ #category : 'defaults' }
GolapGoogleClient >> defaultApikey [

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

{ #category : 'defaults' }
GolapGoogleClient >> defaultCseid [

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
GolapGoogleClient >> golapDirectory [

	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'accessing' }
GolapGoogleClient >> googleUrl [

	^ 'https://customsearch.googleapis.com/customsearch/v1' asZnUrl
]

{ #category : 'accessing' }
GolapGoogleClient >> initialize [

	super initialize.
	params := Dictionary new
		          at: 'searchType' put: 'image';
		          at: 'num' put: 1;
		          yourself
]

{ #category : 'accessing' }
GolapGoogleClient >> paramAt: queryKey ifAbsent: errorBlock [

	^ params at: queryKey ifAbsent: errorBlock
]

{ #category : 'accessing' }
GolapGoogleClient >> paramAt: queryKey ifPresent: aBlock [

	^ params at: queryKey ifPresent: aBlock
]

{ #category : 'accessing' }
GolapGoogleClient >> searchThumbnail: aString [

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
		on: Error
		do: [ :ex |  ].
	^ nil
]

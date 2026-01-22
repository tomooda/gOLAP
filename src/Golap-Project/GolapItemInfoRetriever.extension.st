Extension { #name : 'GolapItemInfoRetriever' }

{ #category : '*Golap-Project' }
GolapItemInfoRetriever >> asJSON [

	^ {
		  ('tag' -> self class tag).
		  ('photoImageRetrievers'
		   -> (photoimageRetrievers asArray collect: #asJSON)) }
		  asDictionary
]

{ #category : '*Golap-Project' }
GolapItemInfoRetriever class >> fromJSON: aDictionary [

	^ (self classForJSON: aDictionary) ifNotNil: [ :subclass |
		  subclass new fromJSON: aDictionary ]
]

{ #category : '*Golap-Project' }
GolapItemInfoRetriever >> fromJSON: aDictionary [

	aDictionary at: 'photoImageRetrievers' ifPresent: [ :array |
			photoimageRetrievers := array collect: [ :json |
					                        ((GolapPhotoImageRetriever classForJSON:
						                          json) for: self) fromJSON: json ] ]
]

Class {
	#name : 'GolapItemView',
	#superclass : 'SpPresenter',
	#instVars : [
		'infoList',
		'itemImage',
		'golap',
		'vertex'
	],
	#classVars : [
		'EmptyImage',
		'ImageRepositoryUrl'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'layout' }
GolapItemView class >> defaultLayout [

	<spec>
	^ SpPanedLayout newVertical
		  positionOfSlider: 0.6;
		  add: #infoList;
		  add: #itemImage;
		  yourself
]

{ #category : 'instance creation' }
GolapItemView class >> on: aGolap [

	^ self new
		  golap: aGolap;
		  yourself
]

{ #category : 'as yet unclassified' }
GolapItemView >> emptyImage [
	^ EmptyImage
		ifNil: [ | image |
			image := Form extent: 16 @ 16 depth: 32.
			image getCanvas fillColor: Color white.
			image ]
]

{ #category : 'as yet unclassified' }
GolapItemView >> golap: aGolap [
	golap := aGolap
]

{ #category : 'initialization' }
GolapItemView >> initializePresenters [

	infoList := self newTable
		            enabled: false;
		            addColumn:
			            (SpStringTableColumn new evaluated: [ :assoc |
					             assoc key asString ]);
		            addColumn:
			            (SpStringTableColumn new evaluated: [ :assoc |
					             assoc value asString ]);
		            yourself.
	itemImage := self newImage
		             switchAutoscale;
		             yourself
]

{ #category : 'snapshot' }
GolapItemView >> restore: aStream [

	(NeoJSONReader on: aStream) next ifNotNil: [ :json |
		golap productInfoRetriever:
			(GolapProductInfoRetriever fromJSON: json) ]
]

{ #category : 'snapshot' }
GolapItemView >> snapshot [

	golap snapshotItemView: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapItemView >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut:
		golap productInfoRetriever asJSON
]

{ #category : 'updating' }
GolapItemView >> updateImage [

	vertex ifNotNil: [
		(golap productInfoRetriever photoimageFor: vertex)
			ifNotNil: [ :photoimage |
				vertex photoimage ifNil: [
					vertex photoimage: (photoimage scaledToSize: 64 @ 64) ].
				itemImage image: photoimage ]
			ifNil: [ itemImage image: self emptyImage ] ]
]

{ #category : 'updating' }
GolapItemView >> updateItemInfo [

	^ infoList items: ((vertex ifNotNil: [
			    golap productInfoRetriever productDataFor: vertex ]) ifNil: [
			   #(  ) ])
]

{ #category : 'accessing' }
GolapItemView >> vertex: aGolapVertex [

	vertex := aGolapVertex.
	[
	self updateImage.
	self updateItemInfo ] forkAt: Processor userBackgroundPriority
]

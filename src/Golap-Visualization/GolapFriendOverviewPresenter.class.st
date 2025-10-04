Class {
	#name : 'GolapFriendOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'friendsRankField',
		'layoutButton'
	],
	#category : 'Golap-Visualization-Friend',
	#package : 'Golap-Visualization',
	#tag : 'Friend'
}

{ #category : 'accessing' }
GolapFriendOverviewPresenter >> availableEdges [

	^ (self golapModelDo: [ :golapModel |
		   golapModel friendsEdges: friendsRankField number ]) ifNil: [
		  Array new ]
]

{ #category : 'layout' }
GolapFriendOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'フレンドランク ' asPresenter expand: false;
				   add: friendsRankField width: 50;
				   add: '    ' asPresenter expand: false;
				   add: layoutButton expand: false;
				   yourself)
		  expand: false;
		  add: roassal expand: true;
		  yourself
]

{ #category : 'updating' }
GolapFriendOverviewPresenter >> friendsRankChanged [

	self golapModelDo: [ :golapModel |
		golapModel friendsEdges: friendsRankField number ].
	self updateCanvas
]

{ #category : 'initialization' }
GolapFriendOverviewPresenter >> initializePresenters [

	super initializePresenters.
	friendsRankField := self newNumberInput
		                    beInteger;
		                    placeholder: 'フレンドランク数';
		                    minimum: 1;
		                    number: 5;
		                    autoAccept: true;
		                    whenSubmitDo: [ :txt | self friendsRankChanged ];
		                    yourself.
	layoutButton := self newButton
		                label: ' 再配置 ';
		                action: [
				                golap
					                updateGlobalImageAfter: [
						                golap model friendsEdges:
								                friendsRankField number ]
					                layout: true.
				                self zoomToFit ];
		                yourself
]

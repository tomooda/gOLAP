Class {
	#name : 'GolapCSVLauncher',
	#superclass : 'SpPresenter',
	#instVars : [
		'nodeImporterPresenter',
		'edgeImporterPresenter',
		'launchButton'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'layout' }
GolapCSVLauncher class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: #nodeImporterPresenter expand: true;
				   add: #edgeImporterPresenter expand: true;
				   yourself)
		  expand: true;
		  add: #launchButton expand: false;
		  yourself
]

{ #category : 'instance creation' }
GolapCSVLauncher class >> open [

	<script: 'GolapCSVLauncher open'>
	^ self new open
]

{ #category : 'initialization' }
GolapCSVLauncher >> initializePresenters [

	super initializePresenters.
	nodeImporterPresenter := self instantiate:
		                         GolapCSVNodeImporterPresenter.
	edgeImporterPresenter := self instantiate:
		                         GolapCSVEdgeImporterPresenter.
	launchButton := self newButton
		                label: 'launch';
		                action: [ self launch ]
]

{ #category : 'operations' }
GolapCSVLauncher >> launch [

	| golapModel golap |
	golapModel := GolapModel new.
	nodeImporterPresenter loadInto: golapModel.
	edgeImporterPresenter loadInto: golapModel.
	golap := Golap new.
	golap open maximize.
	golap silentAddDimension: golapModel named: 'CSV'.
	golap updateDimensions.
	golap updateModel.
	golap numFriends: 5.
	golap updateGlobalImageAfter: [  ] layout: true
]

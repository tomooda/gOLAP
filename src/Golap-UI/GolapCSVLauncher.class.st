Class {
	#name : 'GolapCSVLauncher',
	#superclass : 'SpPresenter',
	#instVars : [
		'nodeImporterPresenter',
		'edgeImporterPresenter',
		'launchButton',
		'launcherIcon'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'layout' }
GolapCSVLauncher class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: (SpBoxLayout newVertical
						    add: '商品CSV' asPresenter expand: false;
						    add: #nodeImporterPresenter expand: true;
						    yourself)
				   expand: true;
				   add: (SpBoxLayout newVertical
						    add: '関連性CSV' asPresenter expand: false;
						    add: #edgeImporterPresenter expand: true;
						    yourself)
				   expand: true;
				   yourself)
		  expand: true;
		  add: #launchButton expand: false;
		  yourself
]

{ #category : 'menus' }
GolapCSVLauncher class >> golapMenuOn: aBuilder [

	<worldMenu>
	(aBuilder item: #'Open pair-CSV')
		parent: 'Golap';
		order: 1;
		target: GolapCSVLauncher;
		selector: #open;
		help: 'Open a pair CSV launcher';
		withSeparatorAfter
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
		                icon: self launcherIcon;
		                label: 'gOLAP';
		                action: [ self launch ]
]

{ #category : 'initialization' }
GolapCSVLauncher >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter
		title: 'gOLAP CSV Launcher';
		initialExtent: 800 @ 600
]

{ #category : 'operations' }
GolapCSVLauncher >> launch [

	| golapModel golap |
	golapModel := GolapModel new.
	nodeImporterPresenter loadInto: golapModel.
	edgeImporterPresenter loadInto: golapModel.
	golap := Golap new.
	golap
		nodeEvaluators: nodeImporterPresenter availableEvaluators;
		edgeEvaluators: edgeImporterPresenter availableEvaluators;
		nodeEvaluator: nodeImporterPresenter evaluator;
		edgeEvaluator: edgeImporterPresenter evaluator;
		productInfoRetriever: (GolapCSVProductInfoRetriever photoUrlColumn:
					 nodeImporterPresenter photoUrlColumn);
		silentAddDimension: golapModel named: 'CSV';
		updateDimensions;
		updateModel;
		numFriends: 5.
	golap open maximize.
	golap updateGlobalImageAfter: [  ] layout: true.
	self window ifNotNil: #close
]

{ #category : 'accessing' }
GolapCSVLauncher >> launcherIcon [

	^ launcherIcon ifNil: [
		  launcherIcon := (PNGReadWriter formFromFileNamed:
			                   FileLocator localDirectory / 'gOLAP'
			                   / 'gOLAP-logo.png') scaledToSize: 32 @ 32 ]
]

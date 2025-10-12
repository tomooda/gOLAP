Class {
	#name : 'GolapCSVLauncher',
	#superclass : 'SpPresenter',
	#instVars : [
		'pairPresenter',
		'pairsTable',
		'addPairButton',
		'removePairButton',
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

	^ SpPanedLayout newVertical
		  positionOfSlider: 0.2;
		  add: (SpBoxLayout newVertical
				   add: #pairsTable expand: true;
				   add: (SpBoxLayout newHorizontal
						    add: #addPairButton expand: false;
						    add: #removePairButton expand: false)
				   expand: false);
		  add: (SpBoxLayout newVertical
				   add: (SpBoxLayout newHorizontal
						    add: (SpBoxLayout newHorizontal
								     add: (SpBoxLayout newVertical
										      add: 'アイテムCSV' asPresenter expand: false;
										      add: #nodeImporterPresenter expand: true;
										      yourself)
								     expand: true;
								     add: (SpBoxLayout newVertical
										      add: '関連性CSV' asPresenter expand: false;
										      add: #edgeImporterPresenter expand: true;
										      yourself)
								     expand: true;
								     yourself)
						    expand: true);
				   add: #launchButton expand: false;
				   yourself)
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

{ #category : 'operations' }
GolapCSVLauncher >> addPair [

	pairPresenter openDialog okAction: [
			| nodeFile edgeFile selection |
			nodeFile := pairPresenter nodeCSVFileReference.
			edgeFile := pairPresenter edgeCSVFileReference.
			(nodeFile notNil and: [ edgeFile notNil ]) ifTrue: [
					selection := pairsTable selectedItem.
					pairsTable items: (pairsTable items copyWith: {
								 nodeFile.
								 edgeFile.
								 (pairPresenter pairName ifEmpty: [
									  nodeFile basenameWithoutExtension: 'csv' ]).
								 nil }).
					selection
						ifNotNil: [ pairsTable selectItem: selection ]
						ifNil: [ pairsTable selectIndex: 1 ] ] ]
]

{ #category : 'enumerating' }
GolapCSVLauncher >> dataframePairsAndNamesDo: aBlock [

	pairsTable items do: [ :item |
		item last ifNil: [
			| csv1 csv2 |
			csv1 := nil.
			csv2 := nil.
			item first isFile ifTrue: [
				csv1 := DataFrame readFromCsv: item first ].
			item second isFile ifTrue: [
				csv2 := DataFrame readFromCsv: item second ].
			(csv1 notNil and: [ csv2 notNil ]) ifTrue: [
				item at: item size put: {
						csv1.
						csv2 } ] ].
		item last ifNotNil: [ :pair |
			aBlock value: pair first value: pair second value: item third ] ]
]

{ #category : 'enumerating' }
GolapCSVLauncher >> golapModelsAndNamesDo: aBlock [

	self dataframePairsAndNamesDo: [ :nodeDataframe :edgeDataframe :name |
		| golapModel |
		golapModel := GolapModel new.
		golapModel
			readNodeDataframe: nodeDataframe
			idColumn: nodeImporterPresenter idColumn
			nameColumn: nodeImporterPresenter nameColumn;
			nodeAggregators: nodeImporterPresenter createAggregators;
			nodeEvaluator: nodeImporterPresenter evaluator.
		golapModel
			readEdgeDataframe: edgeDataframe
			idColumn: edgeImporterPresenter idColumn1
			and: edgeImporterPresenter idColumn2;
			edgeAggregators: edgeImporterPresenter createAggregators;
			edgeEvaluator: edgeImporterPresenter evaluator.
		aBlock value: golapModel value: name ]
]

{ #category : 'initialization' }
GolapCSVLauncher >> initializePresenters [

	super initializePresenters.
	pairPresenter := GolapCSVPairPresenter new.
	pairsTable := self newTable
		              addColumn: (SpStringTableColumn
				               title: 'アイテムCSV'
				               evaluated: [ :pair | pair first basename ]);
		              addColumn: (SpStringTableColumn
				               title: '関連CSV'
				               evaluated: [ :pair | pair second basename ]);
		              addColumn: (SpStringTableColumn
				               title: 'ディメンジョン名'
				               evaluated: [ :pair | pair third ]);
		              whenSelectedItemChangedDo: [ self selectedPairChanged ];
		              yourself.
	addPairButton := self newButton
		                 icon: (self iconNamed: #add);
		                 action: [ self addPair ];
		                 yourself.
	removePairButton := self newButton
		                    icon: (self iconNamed: #delete);
		                    action: [ self removePair ];
		                    yourself.
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

	| golap |
	golap := Golap new.
	golap
		nodeEvaluators: nodeImporterPresenter availableEvaluators;
		edgeEvaluators: edgeImporterPresenter availableEvaluators;
		nodeEvaluator: nodeImporterPresenter evaluator;
		edgeEvaluator: edgeImporterPresenter evaluator;
		itemInfoRetriever: (GolapNodeProductInfoRetriever
				 photoUrlColumn: nodeImporterPresenter photoUrlColumn
				 availableColumns: nodeImporterPresenter availableColumns).
	self golapModelsAndNamesDo: [ :golapModel :name |
		golap silentAddDimension: golapModel named: name ].
	golap
		snapshotBaseName: pairPresenter basepathReference basename;
		snapshotData.
	golap
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

{ #category : 'operations' }
GolapCSVLauncher >> removePair [

	pairsTable selectedItem ifNotNil: [ :pair |
		pairsTable items: (pairsTable items copyWithout: pair) ]
]

{ #category : 'updating' }
GolapCSVLauncher >> selectedPairChanged [

	pairsTable selectedItem ifNotNil: [ :item |
			item last ifNil: [
					| csv1 csv2 |
					csv1 := nil.
					csv2 := nil.
					item first isFile ifTrue: [
							self
								informUser: 'Reading ' , item first basename
								during: [ :job |
										csv1 := DataFrame
											        readFromCsv: item first
											        interim: [ :v | job progress: v ]
											        frequency: 100 ] ].
					item second isFile ifTrue: [
							self
								informUser: 'Reading ' , item second basename
								during: [ :job |
										csv2 := DataFrame
											        readFromCsv: item second
											        interim: [ :v | job progress: v ]
											        frequency: 100 ] ].
					(csv1 notNil and: [ csv2 notNil ]) ifTrue: [
							item at: item size put: {
									csv1.
									csv2 } ] ].
			item last ifNotNil: [ :pair |
					nodeImporterPresenter dataframe: pair first.
					edgeImporterPresenter dataframe: pair second ] ]
]

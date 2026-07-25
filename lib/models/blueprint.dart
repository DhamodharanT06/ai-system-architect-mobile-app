// ignore_for_file: invalid_annotation_target
import 'package:hive/hive.dart';

part 'blueprint.g.dart';

@HiveType(typeId: 0)
class Blueprint extends HiveObject {
  @HiveField(0) String projectName;
  @HiveField(1) String description;
  @HiveField(2) String problemStatement;
  @HiveField(3) List<ArchitectureComponent> systemArchitecture;
  @HiveField(4) List<TechStackItem> techStack;
  @HiveField(5) List<WorkflowStep> workflow;
  @HiveField(6) List<PrerequisiteItem> prerequisites;
  @HiveField(7) List<SolutionApproach> solutionApproaches;
  @HiveField(8) List<RealWorldExample> realWorldExamples;
  @HiveField(9) List<LearningReference> learningReferences;
  @HiveField(10) Map<String, String> timeline;
  @HiveField(11) String? estimatedBudget;
  @HiveField(12) List<String> nextSteps;
  @HiveField(13) DateTime createdAt;

  Blueprint({
    required this.projectName,
    required this.description,
    required this.problemStatement,
    required this.systemArchitecture,
    required this.techStack,
    required this.workflow,
    required this.prerequisites,
    required this.solutionApproaches,
    required this.realWorldExamples,
    required this.learningReferences,
    required this.timeline,
    this.estimatedBudget,
    required this.nextSteps,
    required this.createdAt,
  });

  factory Blueprint.fromJson(Map<String, dynamic> j) => Blueprint(
    projectName:        j['project_name']  ?? '',
    description:        j['description']   ?? '',
    problemStatement:   j['problem_statement'] ?? '',
    systemArchitecture: (j['system_architecture'] as List? ?? [])
        .map((e) => ArchitectureComponent.fromJson(e)).toList(),
    techStack:          (j['tech_stack'] as List? ?? [])
        .map((e) => TechStackItem.fromJson(e)).toList(),
    workflow:           (j['workflow'] as List? ?? [])
        .map((e) => WorkflowStep.fromJson(e)).toList(),
    prerequisites:      (j['prerequisites'] as List? ?? [])
        .map((e) => PrerequisiteItem.fromJson(e)).toList(),
    solutionApproaches: (j['solution_approaches'] as List? ?? [])
        .map((e) => SolutionApproach.fromJson(e)).toList(),
    realWorldExamples:  (j['real_world_examples'] as List? ?? [])
        .map((e) => RealWorldExample.fromJson(e)).toList(),
    learningReferences: (j['learning_references'] as List? ?? [])
        .map((e) => LearningReference.fromJson(e)).toList(),
    timeline: Map<String, String>.from(j['timeline'] ?? {}),
    estimatedBudget: j['estimated_budget'],
    nextSteps: List<String>.from(j['next_steps'] ?? []),
    createdAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'project_name':       projectName,
    'description':        description,
    'problem_statement':  problemStatement,
    'system_architecture':systemArchitecture.map((e)=>e.toJson()).toList(),
    'tech_stack':         techStack.map((e)=>e.toJson()).toList(),
    'workflow':           workflow.map((e)=>e.toJson()).toList(),
    'prerequisites':      prerequisites.map((e)=>e.toJson()).toList(),
    'solution_approaches':solutionApproaches.map((e)=>e.toJson()).toList(),
    'real_world_examples':realWorldExamples.map((e)=>e.toJson()).toList(),
    'learning_references':learningReferences.map((e)=>e.toJson()).toList(),
    'timeline':           timeline,
    'estimated_budget':   estimatedBudget,
    'next_steps':         nextSteps,
  };
}

@HiveType(typeId: 1)
class ArchitectureComponent extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String type;
  @HiveField(2) String description;
  @HiveField(3) List<String> responsibilities;
  @HiveField(4) List<String> technologies;

  ArchitectureComponent({
    required this.name, required this.type, required this.description,
    required this.responsibilities, required this.technologies,
  });

  factory ArchitectureComponent.fromJson(Map<String, dynamic> j) =>
      ArchitectureComponent(
        name:             j['name'] ?? '',
        type:             j['type'] ?? '',
        description:      j['description'] ?? '',
        responsibilities: List<String>.from(j['responsibilities'] ?? []),
        technologies:     List<String>.from(j['technologies'] ?? []),
      );

  Map<String, dynamic> toJson() => {
    'name': name, 'type': type, 'description': description,
    'responsibilities': responsibilities, 'technologies': technologies,
  };
}

@HiveType(typeId: 2)
class TechStackItem extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String category;
  @HiveField(2) String reason;
  @HiveField(3) String? version;
  @HiveField(4) List<String> languages;
  @HiveField(5) List<String> frameworks;
  @HiveField(6) List<String> modules;

  TechStackItem({
    required this.name, required this.category, required this.reason,
    this.version, required this.languages,
    required this.frameworks, required this.modules,
  });

  factory TechStackItem.fromJson(Map<String, dynamic> j) => TechStackItem(
    name:       j['name'] ?? '',
    category:   j['category'] ?? '',
    reason:     j['reason'] ?? '',
    version:    j['version'],
    languages:  List<String>.from(j['languages'] ?? []),
    frameworks: List<String>.from(j['frameworks'] ?? []),
    modules:    List<String>.from(j['modules'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'category': category, 'reason': reason,
    'version': version, 'languages': languages,
    'frameworks': frameworks, 'modules': modules,
  };
}

@HiveType(typeId: 3)
class WorkflowStep extends HiveObject {
  @HiveField(0) int stepNumber;
  @HiveField(1) String title;
  @HiveField(2) String description;
  @HiveField(3) List<String> componentsInvolved;
  @HiveField(4) List<String> keyActions;

  WorkflowStep({
    required this.stepNumber, required this.title, required this.description,
    required this.componentsInvolved, required this.keyActions,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> j) => WorkflowStep(
    stepNumber:          j['step_number'] ?? 0,
    title:               j['title'] ?? '',
    description:         j['description'] ?? '',
    componentsInvolved:  List<String>.from(j['components_involved'] ?? []),
    keyActions:          List<String>.from(j['key_actions'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'step_number': stepNumber, 'title': title, 'description': description,
    'components_involved': componentsInvolved, 'key_actions': keyActions,
  };
}

@HiveType(typeId: 4)
class PrerequisiteItem extends HiveObject {
  @HiveField(0) String category;
  @HiveField(1) List<String> items;

  PrerequisiteItem({required this.category, required this.items});

  factory PrerequisiteItem.fromJson(Map<String, dynamic> j) =>
      PrerequisiteItem(category: j['category']??'', items: List<String>.from(j['items']??[]));

  Map<String, dynamic> toJson() => {'category': category, 'items': items};
}

@HiveType(typeId: 5)
class SolutionApproach extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String description;
  @HiveField(2) List<String> pros;
  @HiveField(3) List<String> cons;
  @HiveField(4) String complexity;
  @HiveField(5) String estimatedTime;
  @HiveField(6) String bestFor;

  SolutionApproach({
    required this.name, required this.description, required this.pros,
    required this.cons, required this.complexity,
    required this.estimatedTime, required this.bestFor,
  });

  factory SolutionApproach.fromJson(Map<String, dynamic> j) => SolutionApproach(
    name:          j['name'] ?? '',
    description:   j['description'] ?? '',
    pros:          List<String>.from(j['pros'] ?? []),
    cons:          List<String>.from(j['cons'] ?? []),
    complexity:    j['complexity'] ?? 'Medium',
    estimatedTime: j['estimated_time'] ?? '',
    bestFor:       j['best_for'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'description': description, 'pros': pros,
    'cons': cons, 'complexity': complexity,
    'estimated_time': estimatedTime, 'best_for': bestFor,
  };
}

@HiveType(typeId: 6)
class RealWorldExample extends HiveObject {
  @HiveField(0) String title;
  @HiveField(1) String description;
  @HiveField(2) String company;
  @HiveField(3) String? link;
  @HiveField(4) List<String> lessonsLearned;

  RealWorldExample({
    required this.title, required this.description, required this.company,
    this.link, required this.lessonsLearned,
  });

  factory RealWorldExample.fromJson(Map<String, dynamic> j) => RealWorldExample(
    title:          j['title'] ?? '',
    description:    j['description'] ?? '',
    company:        j['company'] ?? '',
    link:           j['link'],
    lessonsLearned: List<String>.from(j['lessons_learned'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'description': description, 'company': company,
    'link': link, 'lessons_learned': lessonsLearned,
  };
}

@HiveType(typeId: 7)
class LearningReference extends HiveObject {
  @HiveField(0) String title;
  @HiveField(1) String url;
  @HiveField(2) String type;
  @HiveField(3) String difficulty;

  LearningReference({
    required this.title, required this.url,
    required this.type, required this.difficulty,
  });

  factory LearningReference.fromJson(Map<String, dynamic> j) => LearningReference(
    title:      j['title'] ?? '',
    url:        j['url'] ?? '',
    type:       j['type'] ?? 'Guide',
    difficulty: j['difficulty'] ?? 'Beginner',
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'url': url, 'type': type, 'difficulty': difficulty,
  };
}

@HiveType(typeId: 8)
class RuntimeFlowStep extends HiveObject {
  @HiveField(0) String lane;
  @HiveField(1) String type;
  @HiveField(2) String title;
  @HiveField(3) String detail;
  @HiveField(4) String? arrowTo;
  @HiveField(5) String? arrowLabel;

  RuntimeFlowStep({
    required this.lane, required this.type, required this.title,
    required this.detail, this.arrowTo, this.arrowLabel,
  });

  factory RuntimeFlowStep.fromJson(Map<String, dynamic> j) => RuntimeFlowStep(
    lane:       j['lane'] ?? 'backend',
    type:       j['type'] ?? 'process',
    title:      j['title'] ?? '',
    detail:     j['detail'] ?? '',
    arrowTo:    j['arrowTo'],
    arrowLabel: j['arrowLabel'],
  );
}
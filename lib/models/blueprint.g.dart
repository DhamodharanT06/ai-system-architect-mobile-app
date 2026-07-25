// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blueprint.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlueprintAdapter extends TypeAdapter<Blueprint> {
  @override
  final int typeId = 0;

  @override
  Blueprint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Blueprint(
      projectName: fields[0] as String,
      description: fields[1] as String,
      problemStatement: fields[2] as String,
      systemArchitecture: (fields[3] as List).cast<ArchitectureComponent>(),
      techStack: (fields[4] as List).cast<TechStackItem>(),
      workflow: (fields[5] as List).cast<WorkflowStep>(),
      prerequisites: (fields[6] as List).cast<PrerequisiteItem>(),
      solutionApproaches: (fields[7] as List).cast<SolutionApproach>(),
      realWorldExamples: (fields[8] as List).cast<RealWorldExample>(),
      learningReferences: (fields[9] as List).cast<LearningReference>(),
      timeline: (fields[10] as Map).cast<String, String>(),
      estimatedBudget: fields[11] as String?,
      nextSteps: (fields[12] as List).cast<String>(),
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Blueprint obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.projectName)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.problemStatement)
      ..writeByte(3)
      ..write(obj.systemArchitecture)
      ..writeByte(4)
      ..write(obj.techStack)
      ..writeByte(5)
      ..write(obj.workflow)
      ..writeByte(6)
      ..write(obj.prerequisites)
      ..writeByte(7)
      ..write(obj.solutionApproaches)
      ..writeByte(8)
      ..write(obj.realWorldExamples)
      ..writeByte(9)
      ..write(obj.learningReferences)
      ..writeByte(10)
      ..write(obj.timeline)
      ..writeByte(11)
      ..write(obj.estimatedBudget)
      ..writeByte(12)
      ..write(obj.nextSteps)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlueprintAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArchitectureComponentAdapter extends TypeAdapter<ArchitectureComponent> {
  @override
  final int typeId = 1;

  @override
  ArchitectureComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArchitectureComponent(
      name: fields[0] as String,
      type: fields[1] as String,
      description: fields[2] as String,
      responsibilities: (fields[3] as List).cast<String>(),
      technologies: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArchitectureComponent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.responsibilities)
      ..writeByte(4)
      ..write(obj.technologies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchitectureComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TechStackItemAdapter extends TypeAdapter<TechStackItem> {
  @override
  final int typeId = 2;

  @override
  TechStackItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TechStackItem(
      name: fields[0] as String,
      category: fields[1] as String,
      reason: fields[2] as String,
      version: fields[3] as String?,
      languages: (fields[4] as List).cast<String>(),
      frameworks: (fields[5] as List).cast<String>(),
      modules: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TechStackItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.version)
      ..writeByte(4)
      ..write(obj.languages)
      ..writeByte(5)
      ..write(obj.frameworks)
      ..writeByte(6)
      ..write(obj.modules);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechStackItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkflowStepAdapter extends TypeAdapter<WorkflowStep> {
  @override
  final int typeId = 3;

  @override
  WorkflowStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkflowStep(
      stepNumber: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      componentsInvolved: (fields[3] as List).cast<String>(),
      keyActions: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkflowStep obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.stepNumber)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.componentsInvolved)
      ..writeByte(4)
      ..write(obj.keyActions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrerequisiteItemAdapter extends TypeAdapter<PrerequisiteItem> {
  @override
  final int typeId = 4;

  @override
  PrerequisiteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrerequisiteItem(
      category: fields[0] as String,
      items: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PrerequisiteItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrerequisiteItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SolutionApproachAdapter extends TypeAdapter<SolutionApproach> {
  @override
  final int typeId = 5;

  @override
  SolutionApproach read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SolutionApproach(
      name: fields[0] as String,
      description: fields[1] as String,
      pros: (fields[2] as List).cast<String>(),
      cons: (fields[3] as List).cast<String>(),
      complexity: fields[4] as String,
      estimatedTime: fields[5] as String,
      bestFor: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SolutionApproach obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.pros)
      ..writeByte(3)
      ..write(obj.cons)
      ..writeByte(4)
      ..write(obj.complexity)
      ..writeByte(5)
      ..write(obj.estimatedTime)
      ..writeByte(6)
      ..write(obj.bestFor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolutionApproachAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RealWorldExampleAdapter extends TypeAdapter<RealWorldExample> {
  @override
  final int typeId = 6;

  @override
  RealWorldExample read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RealWorldExample(
      title: fields[0] as String,
      description: fields[1] as String,
      company: fields[2] as String,
      link: fields[3] as String?,
      lessonsLearned: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RealWorldExample obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.company)
      ..writeByte(3)
      ..write(obj.link)
      ..writeByte(4)
      ..write(obj.lessonsLearned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealWorldExampleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningReferenceAdapter extends TypeAdapter<LearningReference> {
  @override
  final int typeId = 7;

  @override
  LearningReference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningReference(
      title: fields[0] as String,
      url: fields[1] as String,
      type: fields[2] as String,
      difficulty: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LearningReference obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningReferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RuntimeFlowStepAdapter extends TypeAdapter<RuntimeFlowStep> {
  @override
  final int typeId = 8;

  @override
  RuntimeFlowStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RuntimeFlowStep(
      lane: fields[0] as String,
      type: fields[1] as String,
      title: fields[2] as String,
      detail: fields[3] as String,
      arrowTo: fields[4] as String?,
      arrowLabel: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RuntimeFlowStep obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lane)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.detail)
      ..writeByte(4)
      ..write(obj.arrowTo)
      ..writeByte(5)
      ..write(obj.arrowLabel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuntimeFlowStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

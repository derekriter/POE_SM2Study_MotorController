abstract class DataSource {
  final DataType type;
  final dynamic Function(int) getValueAtTimestamp;

  const DataSource({required this.type, required this.getValueAtTimestamp});
}

enum DataType { continous, discrete }

class ContinousDataSource extends DataSource {
  const ContinousDataSource({required num Function(int) getValueAtTimestamp})
    : super(type: DataType.continous, getValueAtTimestamp: getValueAtTimestamp);
}

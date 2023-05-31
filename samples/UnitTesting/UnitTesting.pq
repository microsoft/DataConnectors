section UnitTesting;

shared UnitTesting.ReturnsABC = () => "ABC";
shared UnitTesting.Returns123 = () => "123";
shared UnitTesting.ReturnsTableWithFiveRows = () => Table.Repeat(#table({"a"}, {{1}}), 5);

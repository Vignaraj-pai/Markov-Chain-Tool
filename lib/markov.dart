class Markov {
  late int nNodes;
  late List<double> transitionMatrix;
  late bool validTransitionMatrix = false;

  Markov(int nNodes) {
    this.nNodes = nNodes;
    transitionMatrix = List.filled(nNodes * nNodes, 0.0);
  }

  void setTransition(int i, int j, double value) {
    transitionMatrix[i * nNodes + j] = value;
  }

  void setTransitionMatrix(List<double> newTransitionMatrix) {
    print(newTransitionMatrix.length);
    for (int i = 0; i < nNodes * nNodes; i++) {
      transitionMatrix[i] = newTransitionMatrix[i];
    }

    validTransitionMatrix = checkTransitionMatrix();
  }

  bool checkTransitionMatrix() {
    // Check if the transition matrix is square
    if (nNodes * nNodes != transitionMatrix.length) return false;

    // Check if the transition matrix is stochastic
    for (int i = 0; i < nNodes; i++) {
      double sum = 0.0;
      for (int j = 0; j < nNodes; j++) {
        sum += transitionMatrix[i * nNodes + j];
      }
      if (sum != 1.0) return false;
    }

    return true;
  }

  // List<double> matrixMultiply(List<double> matrix1, int rows1, int columns1, List<double> matrix2, int rows2, int columns2) {
  //   if (columns1 != rows2) return [];
  //   List<double> resultMatrix = List.filled(rows1 * columns2, 0.0);

  //   for (int i = 0; i < rows1; i++) {
  //     for (int j = 0; j < columns2; j++) {
  //       double sum = 0.0;
  //       for (int k = 0; k < columns1; k++) {
  //         sum += matrix1[i * columns1 + k] * matrix2[k * columns2 + j];
  //       }
  //       resultMatrix[i * columns2 + j] = sum;
  //     }
  //   }

  //   return resultMatrix;
  // }

  // List<double> matrixSum(List<double> matrix1, int rows1, int columns1, List<double> matrix2, int rows2, int columns2) {
  //   if (rows1 != rows2 || columns1 != columns2) return [];
  //   List<double> resultMatrix = List.filled(rows1 * columns1, 0.0);

  //   for (int i = 0; i < rows1; i++) {
  //     for (int j = 0; j < columns1; j++) {
  //       resultMatrix[i * columns1 + j] = matrix1[i * columns1 + j] + matrix2[i * columns1 + j];
  //     }
  //   }

  //   return resultMatrix;
  // }

  // Modify matrixMultiply function
List<double> matrixMultiply(List<double> matrix1, int rows1, int columns1, List<double> matrix2, int rows2, int columns2) {
    if (columns1 != rows2) return [];

    List<double> resultMatrix = List.filled(rows1 * columns2, 0.0);

    for (int i = 0; i < rows1; i++) {
        for (int j = 0; j < columns2; j++) {
            double sum = 0.0;
            for (int k = 0; k < columns1; k++) {
                sum += matrix1[i * columns1 + k] * matrix2[k * columns2 + j];
            }
            resultMatrix[i * columns2 + j] = sum;
        }
    }

    return resultMatrix;
}

// Modify matrixSum function
List<double> matrixSum(List<double> matrix1, int rows1, int columns1, List<double> matrix2, int rows2, int columns2) {
    if (rows1 != rows2 || columns1 != columns2) return [];

    List<double> resultMatrix = List.filled(rows1 * columns1, 0.0);

    for (int i = 0; i < rows1; i++) {
        for (int j = 0; j < columns1; j++) {
            resultMatrix[i * columns1 + j] = matrix1[i * columns1 + j] + matrix2[i * columns1 + j];
        }
    }

    return resultMatrix;
}



  void displayAll() {
    // Display the transition matrix
    print("Transition Matrix:");
    for (int i = 0; i < nNodes; i++) {
      for (int j = 0; j < nNodes; j++) {
        print("${transitionMatrix[i * nNodes + j]} ");
      }
      print('');
    }
  }
}

class AbsorbingMarkov extends Markov {

  late int pNodes;
  late int qNodes;
  late List<double> matrixP;
  late List<double> matrixQ;
  late List<int> indexTo;
  late List<int> indexFrom;

  AbsorbingMarkov(int nNodes) : super(nNodes);

  bool isAbsorbingState(int i) {
  double sum = 0.0;
  for (int j = 0; j < nNodes; j++) {
    sum += transitionMatrix[i * nNodes + j];
  }
  // Allow for a small tolerance (e.g., 1e-10) to account for precision issues
  return (sum - 1.0).abs() < 1e-10 && transitionMatrix[i * nNodes + i] == 1.0;
}


  void convertToCanonicalForm() {
    // Initialize the absorbing matrix
    List<int> absorbingStates = List.filled(nNodes, 0);

    for (int i = 0; i < nNodes; i++) {
      if (isAbsorbingState(i)) {
        absorbingStates[i] = 1;
      } else {
        absorbingStates[i] = 0;
      }
    }

    // Matrix needs to be converted to the form: [P Q] [0 I]

    List<int> indexOrder = List.filled(nNodes, 0);

    int pIndex = 0;
    int qIndex = 0;

    for (int i = 0; i < nNodes; i++) {
      if (absorbingStates[i] == 0) {
        indexOrder[pIndex++] = i;
      } else {
        indexOrder[nNodes - qIndex++ - 1] = i;
      }
    }

    // Initialize the P matrix
    matrixP = List.filled(pIndex * pIndex, 0.0);
    for (int i = 0; i < pIndex; i++) {
      for (int j = 0; j < pIndex; j++) {
        matrixP[i * pIndex + j] = transitionMatrix[indexOrder[i] * nNodes + indexOrder[j]];
      }
    }

    // Initialize the Q matrix
    matrixQ = List.filled(pIndex * qIndex, 0.0);
    for (int i = 0; i < pIndex; i++) {
      for (int j = 0; j < qIndex; j++) {
        matrixQ[i * qIndex + j] = transitionMatrix[indexOrder[i] * nNodes + indexOrder[j + pIndex]];
      }
    }

    // Update the number of nodes
    pNodes = pIndex;
    qNodes = qIndex;

    // Calculate index maps
    indexTo = indexOrder;
    indexFrom = List.filled(nNodes, 0);
    // Calculate index_from
    for (int i = 0; i < nNodes; i++) {
      indexFrom[indexTo[i]] = i;
    }
  }

  @override
  void displayAll() {
    convertToCanonicalForm();

    // Display the transition matrix
    print("Transition Matrix:");
    for (int i = 0; i < nNodes; i++) {
      for (int j = 0; j < nNodes; j++) {
        print("${transitionMatrix[i * nNodes + j]}  ");
      }
      print('\n');
    }

    print("\n\n\n");

    // Display the P matrix
    print("P Matrix:");
    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < pNodes; j++) {
        print("${matrixP[i * pNodes + j]}  ");
      }
      print('\n');
    }

    print("\n\n\n");

    // Display the Q matrix
    print("Q Matrix:");
    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < qNodes; j++) {
        print("${matrixQ[i * qNodes + j]}  ");
      }
      print('\n');
    }

    print("\n\n\n");
  }

  List<double> raisePToPower(int power) {
    // Create two copies of the P matrix
    List<double> matrixPCopy1 = List.from(matrixP);
    List<double> matrixPCopy2 = List.from(matrixP);

    // Raise the matrix to the power
    for (int i = 0; i < power - 1; i++) {
      if (i % 2 == 0) {
        matrixPCopy1 = matrixMultiply(matrixP, pNodes, pNodes, matrixPCopy2, pNodes, pNodes);
      } else {
        matrixPCopy2 = matrixMultiply(matrixP, pNodes, pNodes, matrixPCopy1, pNodes, pNodes);
      }
    }

    if (power % 2 == 0) {
      return List.from(matrixPCopy1);
    } else {
      return List.from(matrixPCopy2);
    }
  }

  List<double> geometricSumP(int power) {
    // Create the result matrix
    List<double> geometricSum = List.filled(pNodes * pNodes, 0.0);

    // Initialize the result matrix with the identity matrix
    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < pNodes; j++) {
        geometricSum[i * pNodes + j] = (i == j) ? 1 : 0;
      }
    }

    // Create two copies of the P matrix
    List<double> matrixPCopy1 = List.filled(pNodes * pNodes, 0.0);
    List<double> matrixPCopy2 = List.filled(pNodes * pNodes, 0.0);

    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < pNodes; j++) {
        matrixPCopy1[i * pNodes + j] = (i == j) ? 1 : 0;
        matrixPCopy2[i * pNodes + j] = (i == j) ? 1 : 0;
      }
    }

    // Calculate the geometric sum
    // for (int i = 0; i < power; i++) {
    //   if (i % 2 == 0) {
    //     geometricSum = matrixSum(geometricSum, pNodes, pNodes, matrixMultiply(matrixP, pNodes, pNodes, matrixPCopy2, pNodes, pNodes), pNodes, pNodes);
    //   } else {
    //     geometricSum = matrixSum(geometricSum, pNodes, pNodes, matrixMultiply(matrixP, pNodes, pNodes, matrixPCopy1, pNodes, pNodes), pNodes, pNodes);
    //   }
    // }

    // Calculate the geometric sum
    for (int i = 0; i < power; i++) {
      if (i % 2 == 0) {
        matrixPCopy1 = matrixMultiply(matrixP, pNodes, pNodes, matrixPCopy2, pNodes, pNodes);
      } else {
        matrixPCopy2 = matrixMultiply(matrixP, pNodes, pNodes, matrixPCopy1, pNodes, pNodes);
      }

      // Update geometricSum based on the current matrix copy
      geometricSum = matrixSum(
        geometricSum,
        pNodes,
        pNodes,
        (i % 2 == 0) ? List.from(matrixPCopy1) : List.from(matrixPCopy2),
        pNodes,
        pNodes,
      );
    }

    return geometricSum;
  }

  List<double> calculateState(List<double> initialState, int timeSteps) {
    // Raise the P matrix to the power of timeSteps
    List<double> matrixPPower = raisePToPower(timeSteps);
    print("Matrix P Power:");
    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < pNodes; j++) {
        print("${matrixPPower[i * pNodes + j]}  ");
      }
      print('\n');
    }

    List<double> matrixPGeometricSum = geometricSumP(timeSteps - 1);
    print("Matrix P Geometric Sum:");
    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < pNodes; j++) {
        print("${matrixPGeometricSum[i * pNodes + j]}  ");
      }
      print('\n');
    }

    List<double> newQ = List.filled(pNodes * qNodes, 0.0);
    newQ = matrixMultiply(matrixPGeometricSum, pNodes, pNodes, matrixQ, pNodes, qNodes);
    print("New Q:");
    for (int i = 0; i < pNodes; i++) {
      for (int j = 0; j < qNodes; j++) {
        print("${newQ[i * qNodes + j]}  ");
      }
      print('\n');
    }

    List<double> finalTransitionMatrix = List.filled(nNodes * nNodes, 0.0);


    for (int i = 0; i < pNodes; i++) {
  for (int j = 0; j < pNodes; j++) {
    finalTransitionMatrix[indexTo[i] * nNodes + indexTo[j]] = matrixPPower[i * pNodes + j];
  }
  for (int j = 0; j < qNodes; j++) {
    finalTransitionMatrix[indexTo[i] * nNodes + indexTo[j + pNodes]] = newQ[i * qNodes + j];
  }
}


    for (int i = pNodes; i < nNodes; i++) {
      for (int j = 0; j < nNodes; j++) {
        finalTransitionMatrix[i * nNodes + j] = (i == j) ? 1 : 0;
      }
    }

    print("Final Transition Matrix:");
    for (int i = 0; i < nNodes; i++) {
      for (int j = 0; j < nNodes; j++) {
        print("${finalTransitionMatrix[i * nNodes + j]}  ");
      }
      print('\n');
    }
    // Calculate the state
    List<double> resultState = List.filled(nNodes, 0.0);
    List<double> indexedState = List.from(initialState);

    resultState = matrixMultiply(indexedState, 1, nNodes, finalTransitionMatrix, nNodes, nNodes);

    // Convert the state to the original indexing
    for (int i = 0; i < nNodes; i++) {
      indexedState[i] = resultState[indexFrom[i]];
    }

    return indexedState;
  }
}
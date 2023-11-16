#include <iostream>

#include "bind.hpp"

class Markov
{
public:
	Markov(int n_nodes);
	~Markov() { delete[] transition_matrix; };

	void set_transition(int i, int j, float value);
	void set_transition_matrix(float* transition_matrix);

	bool check_transition_matrix();

	virtual void display_all();

protected:
	float* matrix_multiply(float* matrix1, int rows1, int columns1, float* matrix2, int rows2, int columns2, float* result_matrix);
	float* matrix_sum(float* matrix1, int rows1, int columns1, float* matrix2, int rows2, int columns2, float* result_matrix);

protected:
	int n_nodes;
	float* transition_matrix;

	bool valid_transition_matrix;
};

// Constructor
Markov::Markov(int n_nodes)
{
	// Initialize the number of nodes
	this->n_nodes = n_nodes;

	// Initialize the transition matrix
	transition_matrix = new float[n_nodes * n_nodes];
}

// Set the transition value
void Markov::set_transition(int i, int j, float value)
{
	transition_matrix[i * n_nodes + j] = value;
}

// Set the transition matrix
void Markov::set_transition_matrix(float* transition_matrix)
{
	for (int i = 0; i < n_nodes * n_nodes; i++)
	{
		this->transition_matrix[i] = transition_matrix[i];
	}

	valid_transition_matrix = check_transition_matrix();
}

// Check if the transition matrix is valid
bool Markov::check_transition_matrix()
{
	// Check if the transition matrix is square
	if(n_nodes * n_nodes != sizeof(transition_matrix))
		return false;

	// Check if the transition matrix is stochastic
	for(int i = 0; i < n_nodes; i++)
	{
		float sum = 0;
		for(int j = 0; j < n_nodes; j++)
			sum += transition_matrix[i * n_nodes + j];

		if(sum != 1.0)
			return false;
	}

	return true;
}

// Multiply two matrices TODO: Optimize this
float* Markov::matrix_multiply(float* matrix1, int rows1, int columns1, float* matrix2, int rows2, int columns2, float* result_matrix)
{
	// Check if the matrices can be multiplied
	if(columns1 != rows2)
		return nullptr;

	// Multiply the matrices
	for(int i = 0; i < rows1; i++)
	{
		for(int j = 0; j < columns2; j++)
		{
			float sum = 0;
			for(int k = 0; k < columns1; k++)
				sum += matrix1[i * columns1 + k] * matrix2[k * columns2 + j];

			result_matrix[i * columns2 + j] = sum;
		}
	}

	return result_matrix;
}

// Sum two matrices TODO: Optimize this
float* Markov::matrix_sum(float* matrix1, int rows1, int columns1, float* matrix2, int rows2, int columns2, float* result_matrix)
{
	// Check if the matrices can be summed
	if(rows1 != rows2 || columns1 != columns2)
		return nullptr;

	// Sum the matrices
	for(int i = 0; i < rows1; i++)
		for(int j = 0; j < columns1; j++)
			result_matrix[i * columns1 + j] = matrix1[i * columns1 + j] + matrix2[i * columns1 + j];

	return result_matrix;
}

// Display all the matrices
void Markov::display_all()
{
	// Display the transition matrix
	std::cout << "Transition Matrix:" << std::endl;
	for(int i = 0; i < n_nodes; i++)
	{
		for(int j = 0; j < n_nodes; j++)
			std::cout << transition_matrix[i * n_nodes + j] << " ";
		std::cout << std::endl;
	}
}

class AbsorbingMarkov : public Markov
{
public:
	AbsorbingMarkov(int n_nodes) : Markov(n_nodes) {};
	~AbsorbingMarkov() { delete[] matrix_P; delete[] matrix_Q; };
	void display_all();
	float* calculate_state(float* initial_state, int time_steps);

private:
	void convert_to_canonical_form();
	bool is_absorbing_state(int i);
	float* raise_P_to_power(int power);
	float* geometric_sum_P(int power);

private:
	int p_nodes;
	int q_nodes;
	float* matrix_P;
	float* matrix_Q;
	int* index_to;
	int* index_from;
};

// Check if the state is absorbing
bool AbsorbingMarkov::is_absorbing_state(int i)
{
	float sum = 0;

	for (int j = 0; j < n_nodes; j++)
		sum += transition_matrix[i * n_nodes + j];

	return sum == 1.0 && transition_matrix[i * n_nodes + i] == 1.0;
}

// Convert transition matrix to absorbing matrix canonical form
void AbsorbingMarkov::convert_to_canonical_form()
{
	// Initialize the absorbing matrix
	int* absorbing_states = new int[n_nodes];
	for(int i = 0; i < n_nodes; i++)
	{
		if(is_absorbing_state(i))
			absorbing_states[i] = 1;
		else
			absorbing_states[i] = 0;
	}

	// Matrix needs to be converted to the form:
	// [P Q]
	// [0 I]

	int* index_order = new int[n_nodes];

	int p_index = 0;
	int q_index = 0;

	for(int i = 0; i < n_nodes; i++)
	{
		if(absorbing_states[i] == 0)
			index_order[p_index++] = i;
		else
			index_order[n_nodes - q_index++ - 1] = i;
	}

	// Initialize the P matrix
	matrix_P = new float[p_index * p_index];
	for(int i = 0; i < p_index; i++)
		for(int j = 0; j < p_index; j++)
			matrix_P[i * p_index + j] = transition_matrix[index_order[i] * n_nodes + index_order[j]];

	// Initialize the Q matrix
	matrix_Q = new float[p_index * q_index];
	for(int i = 0; i < p_index; i++)
		for(int j = 0; j < q_index; j++)
			matrix_Q[i * q_index + j] = transition_matrix[index_order[i] * n_nodes + index_order[j + p_index]];

	// Update the number of nodes
	p_nodes = p_index;
	q_nodes = q_index;

	//Calculate index maps
	index_to = index_order;
	index_from = new int[n_nodes];
	//Calculate index_from
	for(int i = 0; i < n_nodes; i++)
		index_from[index_to[i]] = i;
}

// Display all the matrices
void AbsorbingMarkov::display_all()
{
	convert_to_canonical_form();

	// Display the transition matrix
	std::cout << "Transition Matrix:" << std::endl;
	for(int i = 0; i < n_nodes; i++)
	{
		for(int j = 0; j < n_nodes; j++)
			std::cout << std::scientific << transition_matrix[i * n_nodes + j] << "\t";
		std::cout << std::endl;
	}
	
	std::cout << "\n\n\n";

	// Display the P matrix
	std::cout << "P Matrix:" << std::endl;
	for(int i = 0; i < p_nodes; i++)
	{
		for(int j = 0; j < p_nodes; j++)
			std::cout << std::scientific << matrix_P[i * p_nodes + j] << "\t";
		std::cout << std::endl;
	}
	
	std::cout << "\n\n\n";

	// Display the Q matrix
	std::cout << "Q Matrix:" << std::endl;
	for(int i = 0; i < p_nodes; i++)
	{
		for(int j = 0; j < q_nodes; j++)
			std::cout << std::scientific << matrix_Q[i * q_nodes + j] << "\t";
		std::cout << std::endl;
	}
	
	std::cout << "\n\n\n";
}

// Raise the matrix to a power TODO: Optimize this
float* AbsorbingMarkov::raise_P_to_power(int power)
{
	//Create two copies of the P matrix
	float* matrix_P_copy1 = new float[p_nodes * p_nodes];
	float* matrix_P_copy2 = new float[p_nodes * p_nodes];

	for(int i = 0; i < p_nodes * p_nodes; i++)
	{
		matrix_P_copy1[i] = matrix_P[i];
		matrix_P_copy2[i] = matrix_P[i];
	}

	// Raise the matrix to the power
	for(int i = 0; i < power - 1; i++)
	{
		if(i % 2 == 0)
			matrix_multiply(matrix_P, p_nodes, p_nodes, matrix_P_copy2, p_nodes, p_nodes, matrix_P_copy1);
		else
			matrix_multiply(matrix_P, p_nodes, p_nodes, matrix_P_copy1, p_nodes, p_nodes, matrix_P_copy2);
	}

	if(power % 2 == 0)
	{
		delete[] matrix_P_copy2;
		return matrix_P_copy1;
	}
	else
	{
		delete[] matrix_P_copy1;
		return matrix_P_copy2;
	}
}

// Calculate the geometric sum of the P matrix
float* AbsorbingMarkov::geometric_sum_P(int power)
{
	// Create the result matrix
	float* geometric_sum = new float[p_nodes * p_nodes];

	//Initialize the result matrix with identity matrix
	for(int i = 0; i < p_nodes; i++)
		for(int j = 0; j < p_nodes; j++)
			geometric_sum[i * p_nodes + j] = ((i == j) ? 1 : 0);
	
	//Create two copies of the P matrix
	float* matrix_P_copy1 = new float[p_nodes * p_nodes];
	float* matrix_P_copy2 = new float[p_nodes * p_nodes];

	for(int i = 0; i < p_nodes; i++)
		for(int j = 0; j < p_nodes; j++)
		{
			matrix_P_copy1[i * p_nodes + j] = ((i == j) ? 1 : 0);
			matrix_P_copy2[i * p_nodes + j] = ((i == j) ? 1 : 0);
		}

	//Calculate the geometric sum
	for(int i = 0; i < power; i++)
	{
		if(i % 2 == 0)
			matrix_sum(geometric_sum, p_nodes, p_nodes, matrix_multiply(matrix_P, p_nodes, p_nodes, matrix_P_copy2, p_nodes, p_nodes, matrix_P_copy1), p_nodes, p_nodes, geometric_sum);
		else
			matrix_sum(geometric_sum, p_nodes, p_nodes, matrix_multiply(matrix_P, p_nodes, p_nodes, matrix_P_copy1, p_nodes, p_nodes, matrix_P_copy2), p_nodes, p_nodes, geometric_sum);
	}

	return geometric_sum;
}

// Calculate the state of the system after a given number of time steps
float* AbsorbingMarkov::calculate_state(float* initial_state, int time_steps)
{
	// Raise the P matrix to the power of time_steps
	float* matrix_P_power = raise_P_to_power(time_steps);
	float* matrix_P_geometric_sum = geometric_sum_P(time_steps - 1);

	float* newQ = new float[p_nodes * q_nodes];
	matrix_multiply(matrix_P_geometric_sum, p_nodes, p_nodes, matrix_Q, p_nodes, q_nodes, newQ);

	float* final_transition_matrix = new float[n_nodes * n_nodes];

	for(int i = 0; i < p_nodes; i++)
	{
		for(int j = 0; j < p_nodes; j++)
			final_transition_matrix[i * n_nodes + j] = matrix_P_power[i * p_nodes + j];
		for(int j = 0; j < q_nodes; j++)
			final_transition_matrix[i * n_nodes + j + p_nodes] = newQ[i * q_nodes + j];
	}

	for(int i = p_nodes; i < n_nodes; i++)
		for(int j = 0; j < n_nodes; j++)
			final_transition_matrix[i * n_nodes + j] = (i == j) ? 1 : 0;

	// Calculate the state
	float* result_state = new float[n_nodes];
	float* indexed_state = new float[n_nodes];
	for(int i = 0; i < n_nodes; i++)
		indexed_state[i] = initial_state[index_to[i]];
	matrix_multiply(indexed_state, 1, n_nodes, final_transition_matrix, n_nodes, n_nodes, result_state);
	for(int i = 0; i < n_nodes; i++)
		indexed_state[i] = result_state[index_from[i]];

	delete[] result_state;
	delete[] matrix_P_power;
	delete[] matrix_P_geometric_sum;
	delete[] newQ;
	delete[] final_transition_matrix;

	return indexed_state;
}

EXPORTC void* create_markov_chain(int n_nodes)
{
    return new AbsorbingMarkov(n_nodes);
}

EXPORTC void set_transition_matrix(void* markov_chain, void* transition_matrix)
{
    auto typed_markov_chain = static_cast<AbsorbingMarkov*>(markov_chain);
    auto typed_transition_matrix = static_cast<float*>(transition_matrix);
    typed_markov_chain->set_transition_matrix(typed_transition_matrix);
}

EXPORTC float* calculate_state(void* markov_chain, void* initial_state, int time_steps)
{
    auto typed_markov_chain = static_cast<AbsorbingMarkov*>(markov_chain);
    auto typed_initial_state = static_cast<float*>(initial_state);
    return typed_markov_chain->calculate_state(typed_initial_state, time_steps);
}

// int main()
// {
// 	// Initialize the transition matrix
// 	float transition_matrix[9] = {0.7, 0.1, 0.2, 0.2, 0.4, 0.4, 0, 0, 1};
// 	float initial_state[3] = {1, 0 ,0};
// // 	float transition_matrix[49] = {0.9994208, 9.2e-6, 0, 5.6772e-4, 0, 2.28e-6, 0,0,0.967,0.033,0,0,0,0,0.133,0,0.867,0,0,0,0,0,0,0,0.967,0.033,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0.967,0.033,0.133,0,0,0,0,0,0.867};
// // 	float initial_state[7] = {0.5, 0.5, 0, 0, 0, 0, 0};

// 	// Initialize the Markov Chain
// 	AbsorbingMarkov markov_chain(3);
// 	markov_chain.set_transition_matrix(transition_matrix);
// 	markov_chain.display_all();

// 	float* final_state = markov_chain.calculate_state(initial_state, 100);
// 	std::cout << "\n\nInitial:";
// 	for(int i = 0; i < 3; i++)
// 		std::cout << std::scientific << initial_state[i] << "\t";
// 	std::cout << "\n\n\nFinal: ";
// 	for(int i = 0; i < 3; i++)
// 		std::cout << std::scientific << final_state[i] << "\t";
// 	std::cout << "\n\n\n";

// 	delete[] final_state;
// 	return 0;
// }
import itertools
from dataclasses import dataclass, field
from functools import cache
from types import MappingProxyType
from typing import Self, Mapping
from more_itertools import windowed

INPUT = """
208A
540A
685A
879A
826A
"""
# INPUT = """
# 029A
# 980A
# 179A
# 456A
# 379A
# """

CODES = tuple(l for l in INPUT.split("\n") if l)


@dataclass(frozen=True)
class Path:
    steps: list[tuple["Delta", int]]

    def __str__(self) -> str:
        return "".join(step.char() * distance for step, distance in self.steps)

    def with_suffix(self, suffix: list[tuple["Delta", int]]) -> Self:
        return Path(self.steps + suffix)


@dataclass(frozen=True)
class Delta:
    dx: int
    dy: int

    def char(self) -> str:
        assert abs(self.dx) + abs(self.dy) <= 1
        if self.dx == 1:
            return ">"
        if self.dx == -1:
            return "<"
        if self.dy == 1:
            return "v"
        if self.dy == -1:
            return "^"
        if self.dx == self.dy == 0:
            return "A"
        raise ValueError(f"Invalid delta: {self}")

    @classmethod
    def up(cls):
        return cls(0, -1)

    @classmethod
    def down(cls):
        return cls(0, 1)

    @classmethod
    def left(cls):
        return cls(-1, 0)

    @classmethod
    def right(cls):
        return cls(1, 0)

    def straight_paths(self) -> list[Path]:
        steps = []
        if self.dx:
            steps.append((Delta(self.dx // abs(self.dx), 0), abs(self.dx)))
        if self.dy:
            steps.append((Delta(0, self.dy // abs(self.dy)), abs(self.dy)))
        result = [steps]
        if len(steps) == 2:
            result.append(steps[::-1])
        return [Path(r) for r in result]


@dataclass(frozen=True)
class Point:
    x: int
    y: int

    def step(self, d: Delta) -> Self:
        return Point(self.x + d.dx, self.y + d.dy)


def any_path(paths: list[Path]):
    return paths[0]


@dataclass(frozen=True)
class Pad:
    code_map: Mapping[str, Point] = field(hash=False)
    forbidden_points: frozenset[Point]
    start: Point

    @cache
    def get_paths(self, from_: str, to: str) -> list[Path]:
        from_point = self.code_map[from_]
        to_point = self.code_map[to]
        delta = Delta(to_point.x - from_point.x, to_point.y - from_point.y)
        paths = delta.straight_paths()
        return [p for p in paths if self._valid_path(from_point, p.steps)]

    def _valid_path(self, from_point: Point, path: list[tuple[Delta, int]]) -> bool:
        for step, distance in path:
            for i in range(distance):
                from_point = from_point.step(step)
                if from_point in self.forbidden_points:
                    return False
        return True


# +---+---+---+
# | 7 | 8 | 9 |
# +---+---+---+
# | 4 | 5 | 6 |
# +---+---+---+
# | 1 | 2 | 3 |
# +---+---+---+
#     | 0 | A |
#     +---+---+
NUM_PAD = Pad(
    code_map=MappingProxyType(
        {
            "1": Point(0, 2),
            "2": Point(1, 2),
            "3": Point(2, 2),
            "4": Point(0, 1),
            "5": Point(1, 1),
            "6": Point(2, 1),
            "7": Point(0, 0),
            "8": Point(1, 0),
            "9": Point(2, 0),
            "0": Point(1, 3),
            "A": Point(2, 3),
        }
    ),
    forbidden_points=frozenset([Point(0, 3)]),
    start=Point(2, 3),
)

# < cost

# +---+---+---+
# |   | ^ | A | # двинуть влево
# +---+---+---+
# | < | v | > |
# +---+---+---+

# +---+---+---+
# |   | ^ | A | # нажать на лево
# +---+---+---+
# | < | v | > |
# +---+---+---+

# +---+---+---+
# |   | ^ | A | # увести курсор до кнопки лево и нажать A
# +---+---+---+
# | < | v | > |
# +---+---+---+

# +---+---+---+
# |   | ^ | A | # путешествие до кнопки лево, А, потом путешествие до кнопки А, А
# +---+---+---+
# | < | v | > |
# +---+---+---+

# V<A

ARROW_PAD = Pad(
    code_map=MappingProxyType(
        {
            "v": Point(1, 1),
            "^": Point(1, 0),
            "A": Point(2, 0),
            "<": Point(0, 1),
            ">": Point(2, 1),
        }
    ),
    forbidden_points=frozenset([Point(0, 0)]),
    start=Point(2, 0),
)

PRESS_DIAL_COMPONENT = [Path([(Delta(0, 0), 1)])]


def get_all_atoms():
    chars = list("^v<>") + [""]
    atoms = set()
    for combination in itertools.product(chars, chars, chars):
        atoms.add("".join(combination) + "A")
    return [
        a
        for a in sorted(atoms)
        if "><" not in a and "<>" not in a and "v^" not in a and "^v" not in a
    ]


def strategies_for(path: str) -> list[str]:
    dial_components = []
    atom_strategies = []
    for pair in windowed(itertools.chain("A", path), 2):
        dial_components.append(ARROW_PAD.get_paths(*pair))
        dial_components.append(PRESS_DIAL_COMPONENT)
    for dial_variant in itertools.product(*dial_components):
        atom_strategies.append("".join(str(p) for p in dial_variant))
    return atom_strategies


def generate_strategies(atoms: list[str]) -> list[list[str]]:
    strategies = []
    for atom in atoms:
        strategies.append(strategies_for(atom))
    return strategies


POSSIBLE_ATOMS: list[str] = get_all_atoms()
POSSIBLE_STRATEGIES: list[list[str]] = generate_strategies(POSSIBLE_ATOMS)
ATOM_TO_IDX = {a: i for i, a in enumerate(POSSIBLE_ATOMS)}


def get_numpad_paths(num_path: str) -> list[str]:
    dial_components = []
    possible_paths = []

    for pair in windowed(itertools.chain("A", num_path), 2):
        dial_components.append(NUM_PAD.get_paths(*pair))
        dial_components.append(PRESS_DIAL_COMPONENT)
    for dial_variant in itertools.product(*dial_components):
        possible_paths.append("".join(str(p) for p in dial_variant))
    return possible_paths


@cache
def split_to_atoms_raw(path: str) -> list[str]:
    assert path.endswith("A")
    a_indices = [-1]
    start = 0
    while start != -1:
        start = path.find("A", start)
        if start != -1:
            a_indices.append(start)
            start += 1
    return [path[i + 1 : j + 1] for i, j in windowed(a_indices, 2)]


def split_to_atoms(path: str) -> list[int]:
    atoms = split_to_atoms_raw(path)
    result = [0] * len(POSSIBLE_ATOMS)
    for a in atoms:
        result[ATOM_TO_IDX[a]] += 1
    return result


def take_derivative(
    atoms: list[int], strat: dict[int, int], times: int = 1
) -> list[int]:
    result = result = [0] * len(POSSIBLE_ATOMS)
    for derivative_idx in range(times):
        for idx, atom_count in enumerate(atoms):
            if not atom_count:
                continue

            # best_result = None
            # for s in POSSIBLE_STRATEGIES[idx]:
            #     local_result = [0] * len(POSSIBLE_ATOMS)
            #     for idx, a in enumerate(split_to_atoms(s)):
            #         local_result[idx] += atom_count * a
            #     if best_result is None or atoms_length(local_result) < atoms_length(best_result):
            #         best_result = local_result
            # for idx, a in enumerate(best_result):
            #     result[idx] += a

            any_strategy = POSSIBLE_STRATEGIES[idx][strat[idx]]
            for idx, a in enumerate(split_to_atoms(any_strategy)):
                result[idx] += atom_count * a
        atoms = result
        result = [0] * len(POSSIBLE_ATOMS)
    return atoms


def atoms_length(atoms: list[int]) -> int:
    total = 0
    for atom_idx, count in enumerate(atoms):
        total += count * len(POSSIBLE_ATOMS[atom_idx])
    return total


@cache
def cost_for(path: str, depth: int) -> int:
    if depth == 0:
        return len(path)
    atoms = split_to_atoms(path)
    result_components = []
    for idx, count in enumerate(atoms):
        if not count:
            continue
        result_components.append(POSSIBLE_STRATEGIES[idx])
    min_cost = None
    for comb in itertools.product(*result_components):
        next_atoms = split_to_atoms_raw("".join(comb))
        cost = sum(cost_for(a, depth - 1) for a in next_atoms)
        if min_cost is None or cost < min_cost:
            min_cost = cost
    return min_cost


def solve_for_numpad_memoized(path: str, depth: int) -> int:
    possible_paths = get_numpad_paths(path)
    possible_first_order_paths = set(
        first_order for p in possible_paths for first_order in strategies_for(p)
    )
    min_length = None
    for fo in possible_first_order_paths:
        atoms = split_to_atoms_raw(fo)
        result = sum(cost_for(a, depth=depth - 1) for a in atoms)
        if min_length is None or result < min_length:
            min_length = result
    return min_length * int(path[:-1])


def solve_for_numpad_path(path: str, depth: int, strat: dict[int, int]) -> int:
    possible_paths = get_numpad_paths(path)
    possible_first_order_paths = set(
        first_order for p in possible_paths for first_order in strategies_for(p)
    )
    min_length = None
    for fo in possible_first_order_paths:
        atoms = split_to_atoms(fo)
        derivative_atoms = take_derivative(atoms, strat, depth - 1)
        derivative_len = atoms_length(derivative_atoms)
        if min_length is None or derivative_len < min_length:
            min_length = derivative_len
    return min_length * int(path[:-1])


def solve_for_numpad_path_across_strats(path: str, depth: int) -> int:
    base_strat = {k: 0 for k in range(len(POSSIBLE_STRATEGIES))}
    best_strats = {}
    for idx, strats in enumerate(POSSIBLE_STRATEGIES):
        results = []
        for strat_idx, strat in enumerate(strats):
            strat = base_strat | {idx: strat_idx}
            results.append((strat_idx, solve_for_numpad_path(path, depth, strat)))
        best_strats[idx] = min(results, key=lambda x: x[1])[0]

    return solve_for_numpad_path(path, depth, best_strats)


def main():
    total = 0
    for code in CODES:
        total += solve_for_numpad_memoized(code, 25)
    print(total)


if __name__ == "__main__":
    main()
